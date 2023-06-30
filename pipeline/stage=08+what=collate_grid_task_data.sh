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

STAGE_PATH="${HOME}/scratch/multicell-parasite/data/runmode=${RUNMODE}/stage=08+what=collate_grid_task_data/"
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

python3 - << EOF
import glob
import multiprocessing as mp
import re
import shutil

from keyname import keyname as kn
import pandas as pd

grid_dat_paths = [*glob.glob(
    "${DATA_PATH}/
    stage=06+what=evolve_parasite_with_monopopulation_reseeded_hosts/**/grid_task*.dat",
    recursive=True,
)] + [*glob.glob(
    "${DATA_PATH}/
    stage=07+what=evolve_parasite_with_polypopulation_reseeded_hosts/**/grid_task*.dat",
    recursive=True,
)]

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
        }
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
                "num tasks": (entry > 0) * entry.bit_count(),
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
                }
            )

      dataframes.append(
          pd.DataFrame.from_records(records)
      )

pool = mp.Pool()
dataframes = pool.map(process_one_path, dat_paths)

master_df = pd.concat(
    dataframes
).reset_index(drop=True)
master_df.to_csv("${DATA_PATH}/collated_grid_task-bycell.csv", index=False)

condensed_df = master_df.groupby(
    [
        "stint_uid",
        "deme",
    ],
).max().reset_index()
condensed_df["alive count"] = master_df.groupby(
    [
        "stint_uid",
        "deme",
    ],
).sum().reset_index()["alive"]
condensed_df["task bitfield"] = master_df.groupby(
    [
        "stint_uid",
        "deme",
    ],
).agg(
    lambda x: np.bitwise_or.reduce(x.values),
).reset_index()["task bitfield"]

# Apply logical OR operation across all Series in the list
condensed_df['any tasks'] = np.logical_or.reduce(
    np.column_stack(
        [condensed_df[f'task {task}'] for task in range(32)],
    ),
    axis=1,
)
df["unique tasks"] = sum(
    df[f"task {i}"]
    for i in range(32)
)
condensed_df.to_csv("${DATA_PATH}/collated_grid_task-bydeme.csv", index=False)
EOF


find "${DATA_PATH}/stage=06+what=evolve_parasite_with_monopopulation_reseeded_hosts" -name 'provlog.yaml' -print0 -o \
find "${DATA_PATH}/stage=07+what=evolve_parasite_with_polypopulation_reseeded_hosts" -name 'provlog.yaml' -print0 | \
xargs -0 cat >> "${DATA_PATH}/provlog.yaml"

cat << EOF >> "${DATA_PATH}/provlog.yaml"
-
  a: $(basename "${data_file}.provlog.yaml")
  batch: ${BATCH}
  stage: 8
  date: $(date --iso-8601=seconds)
  hostname: $(hostname)
  path: $(realpath ${data_file})
  revision: ${REVISION}
  runmode: ${RUNMODE}
  user: $(whoami)
  uuid: $(uuidgen)
  shasum256: $(shasum -a256 ${GENOME_PATH} | cut -d " " -f1)
  slurm_job_id: ${SLURM_JOB_ID-none}
  batch_path: $(readlink -f "${BATCH_PATH}")
EOF
done

# deduplicate provlog file
# add trailing whitespace to lines that aren't just -
# deduplicate records separated by -\n
# strip trailing whitespace
# drop extra -\n added to end
# uses inode trick to read/write from same file safely
# https://serverfault.com/a/557566
{ rm -f "${DATA_PATH}/provlog.yaml && sed '/.-/ s/\$/ /' | awk 'BEGIN{RS="-\n"; ORS=RS} !a[\$0]++' - | sed 's/[ \t]*\$//' | head -c -2 > "${DATA_PATH}/provlog.yaml; } < "${DATA_PATH}/provlog.yaml

for f in "${DATA_PATH}"/*.csv; do
  cp "${DATA_PATH}/provlog.yaml" "${f}.provlog.yaml"
done
