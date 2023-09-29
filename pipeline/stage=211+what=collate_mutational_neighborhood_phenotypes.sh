#!/bin/bash

export STAGE="$(echo "$0" | python3 -m keyname.cli extract stage)"
echo "STAGE ${STAGE}"

source "$(dirname "$0")/snippets/setup_instrumentation.sh"

cd "$(dirname "$0")"

RUNMODE="${1}"
echo "RUNMODE ${RUNMODE}"

REVISION="$(git rev-parse --short HEAD)"
echo "REVISION ${REVISION}"

BATCH="date=$(date +%Y-%m-%d)+time=$(date +%H-%M-%S)+revision=${REVISION}+uuid=$(uuidgen)"
echo "BATCH ${BATCH}"

STAGE_PATH="${HOME}/scratch/multicell-parasite/data/runmode=${RUNMODE}/stage=${STAGE}+what=collate_mutational_neighborhood_phenotypes/"
echo "STAGE_PATH ${STAGE_PATH}"

export BATCH_PATH="${STAGE_PATH}/batches/${BATCH}/"
echo "BATCH_PATH ${BATCH_PATH}"

# create data directory
for try in {0..9}; do
  mkdir -p "${BATCH_PATH}" && break
  echo "mkdir -p ${BATCH_PATH} failed (try ${try})"
  SLEEP_DURATION="$((RANDOM % 10 + 1))"
  echo "sleeping ${SLEEP_DURATION} then retrying"
  sleep "${SLEEP_DURATION}"
done

# symlink BATCH to STAGE/latest
for try in {0..9}; do
  ln -srfT "${BATCH_PATH}" "${STAGE_PATH}/latest" && break
  echo "ln -srfT ${BATCH_PATH} ${STAGE_PATH}/latest failed (try ${try})"
  echo "removing ${STAGE_PATH}/latest"
  rm -rf "${STAGE_PATH}/latest"
  SLEEP_DURATION="$((RANDOM % 10 + 1))"
  echo "sleeping ${SLEEP_DURATION} then retrying"
  sleep "${SLEEP_DURATION}"
done

source snippets/setup_production_dependencies.sh

echo "PWD ${PWD}"

DATA_PATH="${HOME}/scratch/multicell-parasite/data/runmode=${RUNMODE}/"
echo "DATA_PATH ${DATA_PATH}"

# provlog
python3 - << EOF
import glob
import re

import multiprocess as mp
from keyname import keyname as kn
from tqdm import tqdm


provlog_paths = [*glob.glob(
    "${DATA_PATH}/stage=210+what=assess_dominant_parasite_mutational_neighborhood_phenotypes/target-epoch=*/latest/provlog.yaml",
    recursive=True,
)]

pool = mp.Pool()
file_contents = []

def read_file(path):
    attrs = kn.unpack(path.replace("/", "+"))
    with open(path, 'r') as file:
        return file.read()

with tqdm(total=len(provlog_paths)) as pbar:
    for result in pool.imap_unordered(read_file, provlog_paths):
        file_contents.append(result)
        pbar.update()

pool.close()
pool.join()

# Concatenate the file contents and write to destination file
with open("${BATCH_PATH}/provlog.yaml", "w") as dest_file:
    dest_file.write("".join(file_contents))

EOF
echo "provlog concatenated"

cat << EOF >> "${BATCH_PATH}/provlog.yaml"
-
  a: $(basename "${BATCH_PATH}.provlog.yaml")
  batch: ${BATCH}
  stage: ${STAGE}
  date: $(date --iso-8601=seconds)
  hostname: $(hostname)
  path: $(realpath ${BATCH_PATH})
  revision: ${REVISION}
  runmode: ${RUNMODE}
  user: $(whoami)
  uuid: $(uuidgen)
  slurm_job_id: ${SLURM_JOB_ID-none}
  batch_path: $(readlink -f "${BATCH_PATH}")
EOF
echo "provlog appended"

# deduplicate provlog file
# add trailing whitespace to lines that aren't just -
# deduplicate records separated by -\n
# strip trailing whitespace
# drop extra -\n added to end
# uses inode trick to read/write from same file safely
# https://serverfault.com/a/557566
{ rm -f "${BATCH_PATH}/provlog.yaml" && sed '/.-/ s/\$/ /' | awk 'BEGIN{RS="-\n"; ORS=RS} !a[$0]++' - | sed 's/[ \t]*\$//' | head -c -2 > "${BATCH_PATH}/provlog.yaml"; } < "${BATCH_PATH}/provlog.yaml"
echo "provlog deduplicated"


# actual data
echo "compiling collated data..."
python3 - << EOF
import glob
import multiprocessing as mp
import re

from keyname import keyname as kn
import numpy as np
import pandas as pd
from tqdm import tqdm
import traceback


def process_one_path(path: str) -> pd.DataFrame:
    return pd.read_csv(path)


def try_process_one_path(path: str) -> pd.DataFrame:
    error = None
    for attempt in range(8):
        try:
            return process_one_path(path)
        except (pd.errors.ParserError, ValueError) as e:
            error = e
            continue

    print(path)
    traceback.print_exception(error)
    print()
    return pd.DataFrame()

paths = [*glob.glob(
    "${DATA_PATH}/stage=210+what=assess_dominant_parasite_mutational_neighborhood_phenotypes/target-epoch=*/latest/what=dominant-phenotype-summaries+epoch=*+ext=.csv",
    recursive=True,
)]

print(f"processing {len(paths)} spop paths...")

pool = mp.Pool(8)
dataframes = []
with tqdm(total=len(paths)) as pbar:
    for result in pool.imap_unordered(try_process_one_path, paths):
        dataframes.append(result)  # Append the returned DataFrame to the list
        pbar.update()

pool.close()
pool.join()

print("concatenating master dataframe")
master_df = pd.concat(
    dataframes,
    ignore_index=True,
)
print("master dataframe concatenated")

outpath = "${BATCH_PATH}/what=collated-phenotype-neighborhoods+ext=.csv.gz"
master_df.to_csv(outpath, compression="gzip", index=False)
print(f"{outpath} saved")
EOF

echo "fin"
