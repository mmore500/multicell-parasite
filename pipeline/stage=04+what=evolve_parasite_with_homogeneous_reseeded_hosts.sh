#!/bin/bash

export STAGE="$(echo "$0" | keyname extract stage)"
echo "STAGE ${STAGE}"

source "$(dirname "$0")/snippets/setup_instrumentation.sh"

cd "$(dirname "$0")"

RUNMODE="${1}"
echo "RUNMODE ${RUNMODE}"

ATTEMPT="${2}"
echo "ATTEMPT ${ATTEMPT}"

REVISION="$(git rev-parse --short HEAD)"
echo "REVISION ${REVISION}"

source snippets/setup_production_dependencies.sh

echo "PWD ${PWD}"

CONFIG_AND_RUN="$(
  cat ../cfg/a=periodic-deme-reseed+what=config-and-run.sh | sed 's/^/  /'
)"

CONTINUATION_TEMPLATE="$(
  cat stage=04+what=evolve_parasite_with_homogeneous_reseed/evolve_parasite_with_homogeneous_reseeded_hosts.slurm.sh.jinja | sed 's/^/  /'
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

NUM_REPS=5
echo "NUM_REPS ${NUM_REPS}"

HOST_PROTOTYPE_GLOB="${HOME}/scratch/multicell-parasite/data/runmode=${RUNMODE}/stage=03+what=translate_host_prototypes/latest/tasks=*/host_prototype.org"
echo "HOST_PROTOTYPE_GLOB ${HOST_PROTOTYPE_GLOB}"

# adapted from https://superuser.com/a/284226
# generated using script/pick_resource_combos.py
for replicate in $(seq "${NUM_REPS}"); do
echo "replicate ${replicate}"
for host_prototype in ${HOST_PROTOTYPE_GLOB}; do
  echo "host_prototype ${host_prototype}"
  SBATCH_SCRIPT_PATH="${SBATCH_SCRIPT_DIRECTORY_PATH}/$(uuidgen).slurm.sh"
  echo "SBATCH_SCRIPT_PATH ${SBATCH_SCRIPT_PATH}"
  j2 --format=yaml -o "${SBATCH_SCRIPT_PATH}" "stage=04+what=evolve_parasite_with_homogeneous_reseeded_hosts/evolve_parasite_with_homogeneous_reseeded_hosts.slurm.sh.jinja" << J2_HEREDOC_EOF
attempt: ${ATTEMPT}
config_and_run: |
${CONFIG_AND_RUN}
continuation_template: |
${CONTINUATION_TEMPLATE}
epoch: 0
install_avida: |
${INSTALL_AVIDA_SNIPPET}
host_prototype_path: $(readlink -f "${host_prototype}")
load_population_path: |
  LOAD_POPULATION_PATH="\$(mktemp)"
  cat << _EOF_ > "\${LOAD_POPULATION_PATH}"
  $(cat ../cfg/smt-empty.spop | sed 's/^/  /')
  _EOF_
load_population_provlog_path: |
  LOAD_POPULATION_PROVLOG_PATH="\$(mktemp)"
  cat << _EOF_ > "\${LOAD_POPULATION_PROVLOG_PATH}"
  $(cat ../cfg/smt-empty.spop.provlog.yaml | sed 's/^/  /')
  _EOF_
replicate: ${replicate}
revision: ${REVISION}
runmode: ${RUNMODE}
setup_instrumentation: |
${SETUP_INSTRUMENTATION_SNIPPET}
setup_production_dependencies: |
${SETUP_PRODUCTION_DEPENDENCIES_SNIPPET}
tasks_slug: $(grep -oP 'tasks=[^/]*' <<< "${host_prototype}" | keyname extract tasks)
tasks_configuration: |
  RESOURCE resECHO:inflow=125:outflow=0.10
  # disable host tasks to avoid weirdness due to having "fast" and "slow" hosts
  # at the same time
J2_HEREDOC_EOF
chmod +x "${SBATCH_SCRIPT_PATH}"

done
done \
  | tqdm \
    --desc "instantiate slurm scripts" \

find "${SBATCH_SCRIPT_DIRECTORY_PATH}" -type f | xargs -L 1 sbatch
