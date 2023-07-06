#!/bin/bash

export STAGE="$(echo "$0" | python3 -m keyname.cli extract stage)"
echo "STAGE ${STAGE}"

source "$(dirname "$0")/snippets/setup_instrumentation.sh"

cd "$(dirname "$0")"

RUNMODE="${1}"
echo "RUNMODE ${RUNMODE}"

ATTEMPT="${2}"
echo "ATTEMPT ${ATTEMPT}"

DEME_RESEED_PERIOD="${3}"
echo "DEME_RESEED_PERIOD ${DEME_RESEED_PERIOD}"

REVISION="$(git rev-parse --short HEAD)"
echo "REVISION ${REVISION}"

source snippets/setup_production_dependencies.sh

echo "PWD ${PWD}"

CONFIG_AND_RUN="$(
  cat ../cfg/a=periodic-deme-reseed+what=config-and-run.sh | sed 's/^/  /'
)"

CONTINUATION_TEMPLATE="$(
  cat stage=${STAGE}+what=evolve_parasite_with_polypopulation_reseeded_hosts/evolve_parasite_with_polypopulation_reseeded_hosts.slurm.sh.jinja | sed 's/^/  /'
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

NUM_REPS=8
echo "NUM_REPS ${NUM_REPS}"

HOST_PROTOTYPE_DIR_GLOB="${HOME}/scratch/multicell-parasite/data/runmode=${RUNMODE}/stage=05+what=prepare_host_protopopulations/latest/tasks=*/"
echo "HOST_PROTOTYPE_DIR_GLOB ${HOST_PROTOTYPE_DIR_GLOB}"

host_prototype_paths="$(for i in {1..40}; do for host_prototype_dir in ${HOST_PROTOTYPE_DIR_GLOB}; do ls -1d "${host_prototype_dir}/"*".org" | shuf --random-source=<(yes "seed${i}" | head -n 100) | awk "NR == $i" | tr '\n' ' '; done; done)"
echo "host_prototype_paths ${host_prototype_paths}"

# adapted from https://superuser.com/a/284226
# generated using script/pick_resource_combos.py
for replicate in $(seq "${NUM_REPS}"); do
echo "replicate ${replicate}"
  SBATCH_SCRIPT_PATH="${SBATCH_SCRIPT_DIRECTORY_PATH}/$(uuidgen).slurm.sh"
  echo "SBATCH_SCRIPT_PATH ${SBATCH_SCRIPT_PATH}"
  j2 --format=yaml -o "${SBATCH_SCRIPT_PATH}" "stage=${STAGE}+what=evolve_parasite_with_polypopulation_reseeded_hosts/evolve_parasite_with_polypopulation_reseeded_hosts.slurm.sh.jinja" << J2_HEREDOC_EOF
inject_parasite_action_prepend: |-
  INJECT_PARASITE_ACTION_PREPEND=""
  DEME_RESEED_PERIOD="${DEME_RESEED_PERIOD}"
  DIV_MUT_PROB=0
  INJECT_MUT_PROB=0
  INJECT_INS_PROB=0
  INJECT_DEL_PROB=0
stage: '${STAGE}'
what: evolve_parasite_with_polypopulation_reseeded_hosts
attempt: ${ATTEMPT}
config_and_run: |
${CONFIG_AND_RUN}
continuation_template: |
${CONTINUATION_TEMPLATE}
epoch: 0
install_avida: |
${INSTALL_AVIDA_SNIPPET}
host_prototype_paths: ${host_prototype_paths}
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
tasks_slug: all
tasks_configuration: |
  RESOURCE resECHO:inflow=125:outflow=0.10
  # disable host task rewards to avoid weirdness due to having "fast" and
  # "slow" hosts at the same time

  REACTION NAND nand process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
  REACTION NOT not process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
  REACTION ORN orn process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
  REACTION LOG3BO logic_3BO process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
  REACTION AND and process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
  REACTION LOG3CI logic_3CI process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
  REACTION ANDN andn process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
  REACTION LOG3BZ logic_3BZ process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
  REACTION LOG3AG logic_3AG process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
  REACTION OR or process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
  REACTION LOG3CP logic_3CP process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
  REACTION LOG3BY logic_3BY process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
  REACTION NOR nor process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
  REACTION LOG3BS logic_3BS process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
  REACTION LOG3BA logic_3BA process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
  REACTION LOG3CJ logic_3CJ process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
  REACTION LOG3AH logic_3AH process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
  REACTION LOG3AQ logic_3AQ process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
  REACTION LOG3CN logic_3CN process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
  REACTION LOG3CB logic_3CB process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
  REACTION LOG3AX logic_3AX process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
  REACTION LOG3AR logic_3AR process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
  REACTION LOG3AO logic_3AO process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
  REACTION LOG3CH logic_3CH process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
  REACTION LOG3CC logic_3CC process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
J2_HEREDOC_EOF
chmod +x "${SBATCH_SCRIPT_PATH}"

done \
  | tqdm \
    --desc "instantiate slurm scripts" \

find "${SBATCH_SCRIPT_DIRECTORY_PATH}" -type f | xargs -L 1 sbatch
