#!/bin/bash

export STAGE="$(echo "$0" | python3 -m keyname.cli extract stage)"
echo "STAGE ${STAGE}"

source "$(dirname "$0")/snippets/setup_instrumentation.sh"

cd "$(dirname "$0")"

RUNMODE="${1}"
echo "RUNMODE ${RUNMODE}"

ATTEMPT="${2}"
echo "ATTEMPT ${ATTEMPT}"

REVISION="$(git rev-parse --short HEAD)"
echo "REVISION ${REVISION}"

BATCH="date=$(date +%Y-%m-%d)+time=$(date +%H-%M-%S)+revision=${REVISION}+uuid=$(uuidgen)"
echo "BATCH ${BATCH}"

source snippets/setup_production_dependencies.sh

echo "PWD ${PWD}"

CONFIG_AND_RUN="$(
  cat ../cfg/a=evolve-host-prototypes+what=config-and-run.sh | sed 's/^/  /'
)"

CONTINUATION_TEMPLATE="$(
  cat stage=00+what=evolve_host_prototypes/evolve_host_prototypes.slurm.sh.jinja | sed 's/^/  /'
)"

INSTALL_AVIDA_SNIPPET="$(
  cat snippets/install_avida.sh | sed 's/^/  /'
)"
SETUP_INSTRUMENTATION_SNIPPET="$(
  cat snippets/setup_instrumentation.sh | sed 's/^/  /'
)"
SETUP_PRODUCTION_DEPENDENCIES_SNIPPET="$(
  cat snippets/setup_production_dependencies.sh | sed 's/^/  /'
)"

SBATCH_SCRIPT_DIRECTORY_PATH="$(mktemp -d)"
echo "SBATCH_SCRIPT_DIRECTORY_PATH ${SBATCH_SCRIPT_DIRECTORY_PATH}"

NUM_JOBS=25
echo "NUM_JOBS ${NUM_JOBS}"

# adapted from https://superuser.com/a/284226
# generated using script/pick_resource_combos.py
for TASKS in stage=00+what=evolve_host_prototypes/tasks/*; do
  echo "tasks_slug $(basename ${TASKS})"
  SBATCH_SCRIPT_PATH="${SBATCH_SCRIPT_DIRECTORY_PATH}/$(uuidgen).slurm.sh"
  echo "SBATCH_SCRIPT_PATH ${SBATCH_SCRIPT_PATH}"
  j2 --format=yaml -o "${SBATCH_SCRIPT_PATH}" "stage=00+what=evolve_host_prototypes/evolve_host_prototypes.slurm.sh.jinja" << J2_HEREDOC_EOF
attempt: ${ATTEMPT}
batch: ${BATCH}
config_and_run: |
${CONFIG_AND_RUN}
continuation_template: |
${CONTINUATION_TEMPLATE}
epoch: 0
install_avida: |
${INSTALL_AVIDA_SNIPPET}
load_population_path: |
  LOAD_POPULATION_PATH="\$(mktemp)"
  for try in {0..9}; do
    URL="https://raw.githubusercontent.com/mmore500/multicell-parasite/${REVISION}/cfg/host-smt-ancestral.spop"
    echo "URL \${URL}"
    curl -L -o "\${LOAD_POPULATION_PATH}" "\${URL}" && break
    echo "curl failed (try \${try})"
    SLEEP_DURATION="\$((RANDOM % 10 + 1))"
    echo "sleeping \${SLEEP_DURATION} then retrying"
    sleep "\${SLEEP_DURATION}"
  done
load_population_provlog_path: |
  LOAD_POPULATION_PROVLOG_PATH="\$(mktemp)"
  for try in {0..9}; do
    URL="https://raw.githubusercontent.com/mmore500/multicell-parasite/${REVISION}/cfg/host-smt-ancestral.spop.provlog.yaml"
    echo "URL \${URL}"
    curl -L -o "\${LOAD_POPULATION_PROVLOG_PATH}" "\${URL}" && break
    echo "curl failed (try \${try})"
    SLEEP_DURATION="\$((RANDOM % 10 + 1))"
    echo "sleeping \${SLEEP_DURATION} then retrying"
    sleep "\${SLEEP_DURATION}"
  done
revision: ${REVISION}
runmode: ${RUNMODE}
setup_instrumentation: |
${SETUP_INSTRUMENTATION_SNIPPET}
setup_production_dependencies: |
${SETUP_PRODUCTION_DEPENDENCIES_SNIPPET}
tasks_slug: $(basename ${TASKS})
tasks_configuration: |
$(cat "${TASKS}" | sed 's/^/  /')
J2_HEREDOC_EOF
chmod +x "${SBATCH_SCRIPT_PATH}"

done \
  | tqdm \
    --desc "instantiate slurm scripts" \
    --total "${NUM_JOBS}"

find "${SBATCH_SCRIPT_DIRECTORY_PATH}" -type f | xargs -L 1 sbatch
