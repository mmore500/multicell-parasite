#!/bin/bash

export STAGE="$(echo "$0" | python3 -m keyname.cli extract stage)"
echo "STAGE ${STAGE}"

source "$(dirname "$0")/snippets/setup_instrumentation.sh"

cd "$(dirname "$0")"

RUNMODE="${1}"
echo "RUNMODE ${RUNMODE}"

# space separated string, generate like `"treata treatb"`
TREATMENTS="ecohost-polyhost"
echo "TREATMENTS ${TREATMENTS}"

NUM_TREATMENTS="$(echo ${TREATMENTS} | wc -w)"
echo "NUM_TREATMENTS ${NUM_TREATMENTS}"

# space separated string, generate like `"{0..9}"`
# monohost identity will be determined modulus replicate number
REPLICATES="$(echo {0..9})"
echo "REPLICATES ${REPLICATES}"

NUM_REPLICATES="$(echo ${REPLICATES} | wc -w)"
echo "NUM_REPLICATES ${NUM_REPLICATES}"

REVISION="$(git rev-parse --short HEAD)"
echo "REVISION ${REVISION}"

BATCH="date=$(date +%Y-%m-%d)+time=$(date +%H-%M-%S)+revision=${REVISION}+uuid=$(uuidgen)"
echo "BATCH ${BATCH}"

source snippets/setup_production_dependencies.sh

echo "PWD ${PWD}"

CONFIG_AND_RUN="$(
  cat ../cfg/a=evolve-parasite-prototype+what=config-and-run.sh | sed 's/^/  /'
)"

CONTINUATION_TEMPLATE="$(
  cat stage=${STAGE}+what=evolve_parasite_prototype/evolve_parasite_prototype.slurm.sh.jinja | sed 's/^/  /'
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

NUM_JOBS="$(( NUM_TREATMENTS * NUM_REPLICATES ))"
echo "NUM_JOBS ${NUM_JOBS}"

# adapted from https://superuser.com/a/284226
# generated using script/pick_resource_combos.py
for treatment in ${TREATMENTS}; do
for replicate in ${REPLICATES}; do
  SBATCH_SCRIPT_PATH="${SBATCH_SCRIPT_DIRECTORY_PATH}/$(uuidgen).slurm.sh"
  echo "SBATCH_SCRIPT_PATH ${SBATCH_SCRIPT_PATH}"
  j2 --format=yaml -o "${SBATCH_SCRIPT_PATH}" "stage=${STAGE}+what=evolve_parasite_prototype/evolve_parasite_prototype.slurm.sh.jinja" << J2_HEREDOC_EOF
batch: ${BATCH}
config_and_run: |
${CONFIG_AND_RUN}
continuation_template: |
${CONTINUATION_TEMPLATE}
epoch: 0
install_avida: |
${INSTALL_AVIDA_SNIPPET}
load_population_path: |
  LOAD_POPULATION_PATH="/dev/null"
load_population_provlog_path: |
  LOAD_POPULATION_PROVLOG_PATH="/dev/null"
replicate: ${replicate}
revision: ${REVISION}
runmode: ${RUNMODE}
setup_instrumentation: |
${SETUP_INSTRUMENTATION_SNIPPET}
setup_production_dependencies: |
${SETUP_PRODUCTION_DEPENDENCIES_SNIPPET}
stage: ${STAGE}
treatment: ${treatment}
J2_HEREDOC_EOF
chmod +x "${SBATCH_SCRIPT_PATH}"
done
done \
  | tqdm \
    --desc "instantiate slurm scripts" \
    --total "${NUM_JOBS}"

find "${SBATCH_SCRIPT_DIRECTORY_PATH}" -type f | xargs -L 1 sbatch
