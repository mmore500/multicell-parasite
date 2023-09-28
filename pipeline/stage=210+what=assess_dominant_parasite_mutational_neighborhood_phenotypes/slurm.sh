#!/bin/bash
########## Define Resources Needed with SBATCH Lines ##########
#SBATCH --time=4:00:00
#SBATCH --job-name stage=210
#SBATCH --account=devolab
#SBATCH --array=0-94
#SBATCH --output="/mnt/home/%u/joblog/id=%A-%a+stage=210+ext.txt"
#SBATCH --mem=8G
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mail-type=FAIL
# No --mail-user, the default value is the submitting user
#SBATCH --exclude=csn-002,amr-250
# Job may be requeued after node failure.
#SBATCH --requeue

echo "SLURM_JOB_ID ${SLURM_JOB_ID}"
echo "SLURM_ARRAY_TASK_ID ${SLURM_ARRAY_TASK_ID}"

SOURCE_URL="https://github.com/mmore500/multicell-parasite.git"
echo "SOURCE_URL ${SOURCE_URL}"
SOURCE_REVISION="2a2e9f8e45bb814831f3a67fa328caac47d561b4"
echo "SOURCE_REVISION ${SOURCE_REVISION}"
SCRIPT_PATH="pipeline/stage=210+what=assess_dominant_parasite_mutational_neighborhood_phenotypes.sh"
echo "SCRIPT_PATH ${SCRIPT_PATH}"
SOURCE_DIR="$(mktemp -d)"
echo "SOURCE_DIR ${SOURCE_DIR}"

module purge || :
module load GCCcore/11.3.0 git/2.36.0-nodocs || :
git clone "${SOURCE_URL}" "${SOURCE_DIR}"
git -C "${SOURCE_DIR}" checkout "${SOURCE_REVISION}"

# Run
cd "${SOURCE_DIR}"
"${SCRIPT_PATH}" production "${SLURM_ARRAY_TASK_ID}"
