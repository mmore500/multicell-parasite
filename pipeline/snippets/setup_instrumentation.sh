#!/bin/bash

set -e
set -o nounset
shopt -s globstar

ln -s "${HOME}/scratch" "/mnt/scratch/${USER}/" || :
mkdir -p "${HOME}/joblog" || :

export JOBSCRIPT_PATH="$0"
echo "JOBSCRIPT_PATH ${JOBSCRIPT_PATH}"
readlink -f "${JOBSCRIPT_PATH}"
export JOBSCRIPT_PATH="$(readlink -f "${JOBSCRIPT_PATH}")"
echo "JOBSCRIPT_PATH ${JOBSCRIPT_PATH}"

mkdir -p "${HOME}/jobscript" || :
cp "${JOBSCRIPT_PATH}" "${HOME}/jobscript/id=${SLURM_JOB_ID:-none}+stage=${STAGE}+ext=.slurm.sh" || :

mkdir -p "${HOME}/jobcont" || :
export JOBCONT_PATH="${HOME}/jobcont/id=${SLURM_JOB_ID:-none}+stage=${STAGE}+ext=.slurm.sh"
echo "JOBCONT_PATH ${JOBCONT_PATH}"
touch "${JOBCONT_PATH}"

err() {
    echo "Error occurred:"
    awk 'NR>L-4 && NR<L+4 { printf "%-5d%3s%s\n",NR,(NR==L?">>>":""),$0 }' L="$1" "$0"
}
trap 'err $LINENO' ERR
