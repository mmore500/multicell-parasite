#!/bin/bash

cd "$(dirname "$0")"

source snippets/setup_instrumentation.sh

RUNMODE="${1}"
echo "RUNMODE ${RUNMODE}"

EPOCH="${2}"
echo "EPOCH ${EPOCH}"

REVISION="$(git rev-parse --short HEAD)"
echo "REVISION ${REVISION}"

BATCH="date=$(date +%Y-%m-%d)+time=$(date +%H-%M-%S)+revision=${REVISION}+uuid=$(uuidgen)"
echo "BATCH ${BATCH}"

STAGE_PATH="${HOME}/scratch/multicell-parasite/data/runmode=${RUNMODE}/stage=01+what=extract_host_prototypes/"
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

# adapted from https://superuser.com/a/284226
# generated using script/pick_resource_combos.py
for replicate_path in "${HOME}/scratch/multicell-parasite/data/runmode=${RUNMODE}/stage=00+what=evolve_host_prototypes/tasks="*; do
  echo "replicate_path ${replicate_path}"

  DATA_PATH="${replicate_path}/latest/alph=*+epoch=${EPOCH}/latest/data"
  DATA_PATH="$(echo ${DATA_PATH})"
  echo "DATA_PATH ${DATA_PATH}"

  if head -c 1 "${DATA_PATH}/grid_task_hosts.5000.dat" | grep -q '^7'; then
    true
  else
    continue
  fi

  GENOME="$(head -n 1 "${DATA_PATH}/host_genome_list.5000.dat")"
  echo "GENOME ${GENOME}"

  OUTPUT_PATH="$(perl -pe 's|\Q/stage=00+what=evolve_host_prototypes/\E|/stage=01+what=extract_host_prototypes/|g' - <<< "${replicate_path}")"
  echo "OUTPUT_PATH ${OUTPUT_PATH}"

  mkdir -p "${OUTPUT_PATH}"
  echo "${GENOME}" > "${OUTPUT_PATH}/host_prototype.org"

  cp "${DATA_PATH}/../provlog.yaml" "${OUTPUT_PATH}/host_prototype.org.provlog.yaml"

  # create provlog
  cat << EOF >> "${OUTPUT_PATH}/host_prototype.org.provlog.yaml"
-
  a: host_prototype.org.provlog.yaml
  batch: ${BATCH}
  stage: 1
  date: $(date --iso-8601=seconds)
  epoch: ${EPOCH}
  hostname: $(hostname)
  path: "${OUTPUT_PATH}/host_prototype.org.provlog.yaml
  revision: ${REVISION}
  runmode: ${RUNMODE}
  user: $(whoami)
  uuid: $(uuidgen)
  shasum256: $(shasum -a256 ${OUTPUT_PATH}/host_prototype.org | cut -d " " -f1)
  slurm_job_id: ${SLURM_JOB_ID-none}
  batch_path: $(readlink -f "${BATCH_PATH}")
EOF


done
