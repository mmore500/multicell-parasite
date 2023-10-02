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

STAGE_PATH="${HOME}/scratch/multicell-parasite/data/runmode=${RUNMODE}/stage=${STAGE}+what=collate_phenotype_grids/"
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
    "${DATA_PATH}/stage=201+what=run_paraevo_treatrepl/treatment=*/alph*replicate*/alph*epoch*/latest/**/provlog.yaml",
    recursive=True,
)]

pool = mp.Pool()
file_contents = []

def read_file(path):
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

from hstrat import _auxiliary_lib as hstrat_auxlib
from keyname import keyname as kn
import numpy as np
import pandas as pd
from tqdm import tqdm
import traceback


from AvidaScripts.GenericScripts.GenomeManipulation import (
    GenomeManipulator,
    make_named_instset_path,
    get_named_instset_content,
)
from AvidaScripts.GenericScripts.PhenotypeAssessment import (
    assess_phenotypes,
    assess_parasite_phenotypes,
    get_named_environment_content,
    load_grid_task_dataframe,
    summarize_mutational_neighborhood_phenotypes,
)
from AvidaScripts.GenericScripts.PopulationManipulation import (
    extract_dominant_taxon,
    load_population_dataframe,
    stitch_population_phylogenies,
)
from AvidaScripts.GenericScripts.MutationalNeighborhood import (
    get_onestep_pointmut_neighborhood,
    sample_twostep_pointmuts,
)


def process_one_path(path: str) -> pd.DataFrame:
    attrs = kn.unpack(path.replace("/", "+"))
    meta = {
        key: attrs[key]
        for key in (
            "replicate",
            "stage",
            "treatment",
        )
    }
    meta["run_uid"] = kn.pack(
        {
            key: meta[key]
            for key in (
                "replicate",
                "treatment"
            )
        },
    )

    para_paths = [
        path
        for path in glob.glob(f"{path}/alph*epoch*/latest/data/grid_task_parasite*.dat")
        if int(kn.unpack(path.replace("/", "+"))["epoch"]) < 95
    ]
    host_paths = [
        path
        for path in glob.glob(f"{path}/alph*epoch*/latest/data/grid_task_hostsite*.dat")
        if int(kn.unpack(path.replace("/", "+"))["epoch"]) < 95
    ]

    para_paths.sort(
        key=lambda path: int(kn.unpack(path.replace("/", "+"))["epoch"]),
    )
    host_paths.sort(
        key=lambda path: int(kn.unpack(path.replace("/", "+"))["epoch"]),
    )

    num_tasks = 25
    dfs = []
    for role, path in tqdm([
        ("parasite", p) for p in para_paths
    ] + [
        ("host", p) for p in host_paths
    ]):
        df = load_grid_task_dataframe(path, num_tasks=num_tasks)
        num_cells_per_deme = 625
        df["Deme ID"] = df["Site"] // num_cells_per_deme

        agg_funcs = {
            "Alive": "sum",
            "Empty": "sum",
            "Num Traits": "mean",
        }
        for i in range(num_tasks):
            agg_funcs[f"Trait {i}"] = "sum"

        agg = df.groupby(
          "Deme ID",
        ).aggregate(
          agg_funcs,
        ).reset_index()

        agg["epoch"] = int(kn.unpack(path.replace("/", "+"))["epoch"])
        agg["role"] = "parasite"
        dfs.append(agg)

    df = pd.concat(dfs, ignore_index=True)

    num_demes_per_partition = 10
    df["Partition ID"] = df["Deme ID"] // num_demes_per_partition

    for key, value in meta.items():
        df[key] = value

    return df


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

spop_paths = [*glob.glob(
    "${DATA_PATH}/stage=201+what=run_paraevo_treatrepl/treatment=*/alph*replicate*/",
    recursive=True,
)]

print(f"processing {len(spop_paths)} spop paths...")

pool = mp.Pool(40)
dataframes = []
with tqdm(total=len(spop_paths)) as pbar:
    for result in pool.imap_unordered(try_process_one_path, spop_paths):
        dataframes.append(result)  # Append the returned DataFrame to the list
        pbar.update()

print("concatenating master dataframe")
master_df = pd.concat(
    dataframes,
    ignore_index=True,
)
print("master dataframe concatenated")

for treat, group in tqdm(master_df.groupby("treatment")):
    outpath = f"${BATCH_PATH}/a=grid_task+what=concat+treatment={treat}+ext=.pqt"
    group.reset_index().to_parquet(
        outpath,
        compression="snappy",
        engine="pyarrow",  # fastparquet fails with overflowerror
        index=False,
    )
    print(f"{outpath} saved")

EOF

echo "fin"
