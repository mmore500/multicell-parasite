#!/bin/bash

set -e

source "$(readlink -f "$(dirname "$0")")/../pipeline/snippets/install_avida.sh"

export AVIDA="${AVIDA:-./avida}"
echo "AVIDA ${AVIDA}"

export EPOCH_COUNTER=0
export EPOCH=0
export EPOCH_=0
export REPLICATE=0

export RANDOM_SEED=1

export NUM_UPDATES_INTRO_SMEAR=100

export TREATMENT="ecohost-monohost"

"$(readlink -f "$(dirname "$0")")/../cfg/a=run-lifetime-peek+what=config-and-run.sh"

tree .

# create provlog
PYSCRIPT=$(cat << HEREDOC
import glob
import multiprocessing as mp
import os
import re

from keyname import keyname as kn
import numpy as np
import pandas as pd
from tqdm import tqdm


def process_one_path(path: str) -> pd.DataFrame:
    stint_uid = path
    meta = {
        "update": int(
            "".join(c for c in os.path.basename(path) if c.isdigit())
        ),
    }
    if "hosts" in path:
        meta["role"] = "host"
    elif "parasite" in path:
        meta["role"] = "parasite"
    else:
        assert False

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
                "site": len(records),
                "deme": len(records) // 225,
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
    "**/grid_task*.dat",
    recursive=True,
)]

pool = mp.Pool(3)

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

outpath = "collated_grid_task-bycell.pqt"
master_df.to_parquet(outpath)

print(f"wrote data to {outpath}")

provlog_path = outpath + ".provlog.yaml"

with open(provlog_path, "w") as provlog_file:
    provlog_file.write(
f"""-
  a: {provlog_path}
  date: $(date --iso-8601=seconds)
  hostname: $(hostname)
  revision: $(git rev-parse HEAD)
  revision_avida: ${AVIDA_REVISION}
  user: $(whoami)
  uuid: $(uuidgen)
  script: $(readlink -f "$0")
  slurm_job_id: ${SLURM_JOB_ID-none}
  pwd: $(pwd)
"""
    )

print(f"wrote provlog to {provlog_path}")

HEREDOC
)
python3 -c "${PYSCRIPT}"
