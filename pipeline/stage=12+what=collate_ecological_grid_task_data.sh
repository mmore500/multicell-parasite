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

STAGE_PATH="${HOME}/scratch/multicell-parasite/data/runmode=${RUNMODE}/stage=${STAGE}+what=collate_ecological_grid_task_data/"
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

MAX_EPOCH=20
echo "MAX_EPOCH ${MAX_EPOCH}"

# provlog
python3 - << EOF
import glob
import re

import multiprocess as mp
from keyname import keyname as kn
from tqdm import tqdm


provlog_paths = [*glob.glob(
    "${DATA_PATH}/stage=10+what=ecological_parasite_with_monopopulation_reseeded+*/**/provlog.yaml",
    recursive=True,
)] + [*glob.glob(
    "${DATA_PATH}/stage=11+what=ecological_parasite_with_polypopulation_reseeded+*/**/proglog.yaml",
    recursive=True,
)]

pool = mp.Pool()
file_contents = []

def read_file(path):
    attrs = kn.unpack(path.replace("/", "+"))
    if int(attrs["epoch"]) < ${MAX_EPOCH}:
        with open(path, 'r') as file:
            return file.read()
    else:
        return ""

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
echo "compiling collated data.."
python3 - << EOF
import glob
import multiprocessing as mp
import re

from keyname import keyname as kn
import numpy as np
import pandas as pd
from tqdm import tqdm


def process_one_path(path: str) -> pd.DataFrame:
    stint_uid = path
    attrs = kn.unpack(path.replace("/", "+"))
    meta = {
        key: attrs[key]
        for key in (
            "DEME_RESEED_PERIOD",
            "epoch",
            "replicate",
            "stage",
            "tasks",
            "what",
        )
    }

    # skip data to keep tractable
    if int(meta["epoch"]) >= ${MAX_EPOCH}:
        return pd.DataFrame()

    meta["treatment"], = [
        m.group() for m in re.finditer("monopopulation", meta["what"])
    ] + [
        m.group() for m in re.finditer("polypopulation", meta["what"])
    ]
    meta["role"], = [
        m.group() for m in re.finditer("task_host", path)
    ] + [
        m.group() for m in re.finditer("task_parasite", path)
    ]
    meta["stint_uid"] = stint_uid
    meta["run_uid"] = kn.pack(
        {
            key: meta[key]
            for key in (
                "replicate",
                "role",
                "tasks",
                "treatment"
            )
        },
    )


    path_df = pd.read_csv(
        path,
        sep=" ",
        header=None,
    ).dropna(axis=1)
    records = []
    for index, row in path_df.iterrows():
        for col in path_df.columns:
            entry = row[col]
            site_data = {
                "alive": int(entry > 0),
                "empty": int(entry == -1),
                "task bitfield" : int((entry > 0) * entry),
                "num tasks": (entry > 0) * int(entry).bit_count(),
                "row": index,
                "col": col,
                "deme": index // 10,
            }
            task_data = {
                f"task {task}": int(
                    (entry > 0) and bool(entry & (1 << task))
                )
                for task in range(32)
            }
            records.append(
                {
                    **site_data,
                    **task_data,
                    **meta,
                },
            )

    return pd.DataFrame.from_records(records)

grid_dat_paths = [*glob.glob(
    "${DATA_PATH}/stage=10+what=ecological_parasite_with_monopopulation_reseeded_hosts+*/**/grid_task*.dat",
    recursive=True,
)] + [*glob.glob(
    "${DATA_PATH}/stage=11+what=ecological_parasite_with_polypopulation_reseeded_hosts+*/**/grid_task*.dat",
    recursive=True,
)]

pool = mp.Pool()
dataframes = []
with tqdm(total=len(grid_dat_paths)) as pbar:
    for result in pool.imap_unordered(process_one_path, grid_dat_paths):
        dataframes.append(result)  # Append the returned DataFrame to the list
        pbar.update()

pool.close()
pool.join()

master_df = pd.concat(
    dataframes
).reset_index(drop=True)
print("master dataframe concatenated")
master_df.to_csv(
  "${BATCH_PATH}/collated_grid_task-bycell.csv",
)
print("${BATCH_PATH}/collated_grid_task-bycell.csv saved")

condensed_df = master_df.groupby(
    [
        "stint_uid",
        "deme",
    ],
).max().reset_index()
print("condensed a")

aggregated_data = master_df.groupby(
    ["stint_uid", "deme"],
).agg(
    {
      "alive": "sum",
      "task bitfield": lambda x: np.bitwise_or.reduce(x.values),
    },
).reset_index()
print("condensed b")

condensed_df["alive count"] = aggregated_data["alive"]
print("condensed c1")
condensed_df["task bitfield"] = aggregated_data["task bitfield"]
print("condensed c2")

# Apply logical OR operation across all Series in the list
condensed_df['any tasks'] = np.logical_or.reduce(
    np.column_stack(
        [condensed_df[f'task {task}'] for task in range(32)],
    ),
    axis=1,
)
print("condensed d")

condensed_df["unique tasks"] = sum(
    condensed_df[f"task {i}"]
    for i in range(32)
)
print("condensed e")


condensed_df.to_csv(
  "${BATCH_PATH}/collated_grid_task-bydeme.csv",
)
print("${BATCH_PATH}/collated_grid_task-bydeme.csv saved")
EOF

echo "fin"
