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
SOURCE_REVISION="535a3e957132e6a078ae60917a76e65aef216ce1"
echo "SOURCE_REVISION ${SOURCE_REVISION}"
SCRIPT_PATH="pipeline/stage=210+what=assess_dominant_parasite_mutational_neighborhood_phenotypes.sh"
echo "SCRIPT_PATH ${SCRIPT_PATH}"
SOURCE_DIR="$(mktemp -d)"
echo "SOURCE_DIR ${SOURCE_DIR}"

cleanup() {
    echo "Cleaning up ${SOURCE_DIR}..."
    rm -rf "${SOURCE_DIR}"
}
# Set the trap to use the cleanup function upon exit.
trap cleanup EXIT

module purge || :
module load ccache/3.3.3 GCCcore/11.3.0 CMake/3.23.1 git/2.36.0-nodocs binutils/2.39 || :
git clone "${SOURCE_URL}" "${SOURCE_DIR}"
git -C "${SOURCE_DIR}" checkout "${SOURCE_REVISION}"

# Run
cd "${SOURCE_DIR}"
"${SCRIPT_PATH}" production "${SLURM_ARRAY_TASK_ID}"
