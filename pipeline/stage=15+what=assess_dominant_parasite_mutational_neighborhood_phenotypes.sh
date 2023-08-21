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

STAGE_PATH="${HOME}/scratch/multicell-parasite/data/runmode=${RUNMODE}/stage=${STAGE}+what=assess_dominant_parasite_mutational_neighborhood_phenotypes/"
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

MAX_EPOCH=200
echo "MAX_EPOCH ${MAX_EPOCH}"

# provlog
python3 - << EOF
import glob
import re

import multiprocess as mp
from keyname import keyname as kn
from tqdm import tqdm


provlog_paths = [*glob.glob(
    "${DATA_PATH}/stage=06+what=evolve_parasite_with_monopopulation_reseeded_hosts/**/latest/**/latest/**/provlog.yaml",
    recursive=True,
)] + [*glob.glob(
    "${DATA_PATH}/stage=07+what=evolve_parasite_with_polypopulation_reseeded_hosts/**/proglog.yaml",
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
echo "compiling collated data..."
python3 - << EOF
import glob
import multiprocessing as mp
import re

from keyname import keyname as kn
import numpy as np
import pandas as pd
from tqdm import tqdm

from AvidaScripts.GenericScripts.GenomeManipulation import (
    GenomeManipulator,
    make_named_instset_path,
    get_named_instset_content,
)
from AvidaScripts.GenericScripts.PhenotypeAssessment import (
    assess_mutational_neighborhood_phenotypes,
    get_named_environment_content,
    summarize_mutational_neighborhood_phenotypes,
)
from AvidaScripts.GenericScripts.PopulationManipulation import (
    extract_dominant_taxon,
    load_population_dataframe,
)
from AvidaScripts.GenericScripts.MutationalNeighborhood import (
    get_onestep_pointmut_neighborhood,
    sample_twostep_pointmuts,
)


def process_one_path(path: str) -> pd.DataFrame:
    stint_uid = path
    attrs = kn.unpack(path.replace("/", "+"))
    meta = {
        key: attrs[key]
        for key in (
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
    meta["stint_uid"] = stint_uid
    meta["run_uid"] = kn.pack(
        {
            key: meta[key]
            for key in (
                "replicate",
                "tasks",
                "treatment"
            )
        },
    )


    pop_df = load_population_dataframe(path)
    manipulator = GenomeManipulator(make_named_instset_path("transsmt"))

    # analyze parasites
    dominant_para_taxon = extract_dominant_taxon(
        pop_df,
        "parasite",
    )
    dominant_para_seq = dominant_para_taxon["Genome Sequence"]
    onestep_para_neighborhood = get_onestep_pointmut_neighborhood(
        dominant_para_seq,
        manipulator,
    )
    twostep_para_neighborhood = sample_twostep_pointmuts(
        dominant_para_seq,
        manipulator,
        n=10000,
    )
    para_neighborhood = {
        **onestep_para_neighborhood,
        **twostep_para_neighborhood,
    }
    para_phenotypes_df = assess_mutational_neighborhood_phenotypes(
        para_neighborhood,
        get_named_environment_content("top25"),
        get_named_instset_content("transsmt"),
        hostify_sequences=True,
    )
    para_summary_df = summarize_mutational_neighborhood_phenotypes(
        para_phenotypes_df,
    )

    for key, value in meta.items():
        para_summary_df[key] = value

    for key, value in dominant_para_taxon.items():
        para_summary_df[f"Reference Taxon {key}"] = value

    return para_summary_df


def try_process_one_path(path: str) -> pd.DataFrame:
    error = None
    for attempt in range(8):
        try:
            return process_one_path(path)
        except pd.errors.ParserError as e:
            error = e
            continue

    print(path, error)
    return pd.DataFrame()

spop_paths = [*glob.glob(
    "${DATA_PATH}/stage=06+what=evolve_parasite_with_monopopulation_reseeded_hosts/*/latest/*+epoch=*0/latest/data/detail*.spop",
    recursive=True,
)] + [*glob.glob(
    "${DATA_PATH}/stage=07+what=evolve_parasite_with_polypopulation_reseeded_hosts/*/latest/*+epoch=*0/latest/data/detail*.spop",
    recursive=True,
)]

print(f"processing {len(spop_paths)} spop paths...")

pool = mp.Pool(16)
dataframes = []
with tqdm(total=len(spop_paths)) as pbar:
    for result in pool.imap_unordered(try_process_one_path, spop_paths):
        dataframes.append(result)  # Append the returned DataFrame to the list
        pbar.update()

pool.close()
pool.join()

master_df = pd.concat(
    dataframes
).reset_index(drop=True)
print("master dataframe concatenated")
master_df.to_csv("${BATCH_PATH}/dominant-phenotype-summaries.csv")
print("${BATCH_PATH}/dominant-phenotype-summaries.csv saved")
EOF

echo "fin"
