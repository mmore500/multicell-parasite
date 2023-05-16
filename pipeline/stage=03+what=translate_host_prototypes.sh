#!/bin/bash

export STAGE="$(echo "$0" | keyname extract stage)"
echo "STAGE ${STAGE}"

source "$(dirname "$0")/snippets/setup_instrumentation.sh"

cd "$(dirname "$0")"

RUNMODE="${1}"
echo "RUNMODE ${RUNMODE}"

REVISION="$(git rev-parse --short HEAD)"
echo "REVISION ${REVISION}"

BATCH="date=$(date +%Y-%m-%d)+time=$(date +%H-%M-%S)+revision=${REVISION}+uuid=$(uuidgen)"
echo "BATCH ${BATCH}"

STAGE_PATH="${HOME}/scratch/multicell-parasite/data/runmode=${RUNMODE}/stage=03+what=translate_host_prototypes/"
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

export TMP_DIR="$(mktemp -d)"
echo "TMP_DIR ${TMP_DIR}"

export CFG_PATH="$(readlink -f ../cfg)"
echo "CFG_PATH ${CFG_PATH}"

(
  cd "${TMP_DIR}"
  export AVIDA=":"
  echo "AVIDA ${AVIDA}"
  "${CFG_PATH}/a=make-host-smt-population+what=config-and-run.sh"
)

# adapted from https://superuser.com/a/284226
# generated using script/pick_resource_combos.py
HOST_PROTOTYPE_GLOB="${HOME}/scratch/multicell-parasite/data/runmode=${RUNMODE}/stage=02+what=select_host_prototypes/latest/tasks=*/host_prototype.org"
for host_prototype_path in ${HOST_PROTOTYPE_GLOB}; do
  echo "host_prototype_path ${host_prototype_path}"

TASKS_KEYNAME="$(grep -oP 'tasks=[^/]*' <<< "${host_prototype_path}")"
echo "TASKS_KEYNAME ${TASKS_KEYNAME}"

OUTPUT_PATH="${BATCH_PATH}/${TASKS_KEYNAME}"
echo "OUTPUT_PATH ${OUTPUT_PATH}"

mkdir -p "${OUTPUT_PATH}"

python3 - > "${OUTPUT_PATH}/host_prototype.org" << EOF
import AvidaScripts
GenomeManipulator = AvidaScripts.GenomeManipulation.GenomeManipulator

manip = GenomeManipulator("${TMP_DIR}/instset-transsmt.cfg")
genome = manip.sequence_to_genome("$(cat "${host_prototype_path}")")
print("\n".join(genome))
EOF

  cp "${host_prototype_path}.provlog.yaml" "${OUTPUT_PATH}/host_prototype.org.provlog.yaml"

  # create provlog
  cat << EOF >> "${OUTPUT_PATH}/host_prototype.org.provlog.yaml"
-
  a: host_prototype.org.provlog.yaml
  batch: ${BATCH}
  stage: 3
  date: $(date --iso-8601=seconds)
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
