#!/bin/bash

export STAGE="05"
echo "STAGE ${STAGE}"

source "$(dirname "$0")/snippets/setup_instrumentation.sh"

cd "$(dirname "$0")"

RUNMODE="${1}"
echo "RUNMODE ${RUNMODE}"

EPOCH="${2}"
echo "EPOCH ${EPOCH}"

REVISION="$(git rev-parse --short HEAD)"
echo "REVISION ${REVISION}"

BATCH="date=$(date +%Y-%m-%d)+time=$(date +%H-%M-%S)+revision=${REVISION}+uuid=$(uuidgen)"
echo "BATCH ${BATCH}"

STAGE_PATH="${HOME}/scratch/multicell-parasite/data/runmode=${RUNMODE}/stage=05+what=prepare_host_protopopulations/"
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

# extract instruction set
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
for replicate_path in "${HOME}/scratch/multicell-parasite/data/runmode=${RUNMODE}/stage=00+what=evolve_host_prototypes/tasks="*; do
  echo "replicate_path ${replicate_path}"

  DATA_PATH="${replicate_path}/latest/alph=*+epoch=${EPOCH}/latest/data"
  DATA_PATH="$(echo ${DATA_PATH})"
  echo "DATA_PATH ${DATA_PATH}"


  TASKS_KEYNAME="$(grep -oP 'tasks=[^/]*' <<< "${replicate_path}")"
  echo "TASKS_KEYNAME ${TASKS_KEYNAME}"

  # use selection we already performed in stage 2 to create stage 3
  if [ -d "${HOME}/scratch/multicell-parasite/data/runmode=${RUNMODE}/stage=03+what=translate_host_prototypes/latest/${TASKS_KEYNAME}" ]; then
    true
  else
    continue
  fi

  # sanity check
  head -c 1 "${DATA_PATH}/grid_task_hosts.5000.dat" | grep -q '^7' || exit 1

  OUTPUT_PATH="${BATCH_PATH}/${TASKS_KEYNAME}"
  echo "OUTPUT_PATH ${OUTPUT_PATH}"

  mkdir -p "${OUTPUT_PATH}"

  seqno=0
  # randomly sample 40 lines
  # to slow to transform all
  for host_prototype_seq in $(shuf -n 49 "${DATA_PATH}/host_genome_list.5000.dat" --random-source=<(yes "${TASKS_KEYNAME}" | head -n 100)); do
    echo "seqno ${seqno}"
    GENOME_PATH="${OUTPUT_PATH}/host_prototype-$(python3 -m alphinity "${seqno}")-${seqno}.org"
python3 - > "${GENOME_PATH}" << EOF
import AvidaScripts
GenomeManipulator = AvidaScripts.GenomeManipulation.GenomeManipulator

manip = GenomeManipulator("${TMP_DIR}/instset-transsmt.cfg")
genome = manip.sequence_to_genome("${host_prototype_seq}")
print("\n".join(genome))
EOF

    cp "${DATA_PATH}/../provlog.yaml" "${GENOME_PATH}.provlog.yaml"
# create provlog
cat << EOF >> "${GENOME_PATH}.provlog.yaml"
-
  a: $(basename "${GENOME_PATH}.provlog.yaml")
  batch: ${BATCH}
  stage: 5
  date: $(date --iso-8601=seconds)
  epoch: ${EPOCH}
  hostname: $(hostname)
  path: ${GENOME_PATH}
  revision: ${REVISION}
  runmode: ${RUNMODE}
  user: $(whoami)
  uuid: $(uuidgen)
  shasum256: $(shasum -a256 ${GENOME_PATH} | cut -d " " -f1)
  slurm_job_id: ${SLURM_JOB_ID-none}
  batch_path: $(readlink -f "${BATCH_PATH}")
EOF

    seqno="$((seqno + 1))"

  done





done
