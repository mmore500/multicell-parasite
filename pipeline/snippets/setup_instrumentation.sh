#!/bin/bash

set -e
set -o nounset
shopt -s globstar

# log context
echo "date $(date)"
echo "hostname $(hostname)"
echo "job ${SLURM_JOB_ID:-none}"
echo "user ${USER}"

ln -s "${HOME}/scratch" "/mnt/scratch/${USER}/" || :
mkdir -p "${HOME}/joblog" || :

if [[ -z ${SLURM_JOB_ID:-} ]]; then
  export JOBLOG_PATH="/dev/null"
else
  export JOBLOG_PATH="$(ls "${HOME}/joblog/"*"id=${SLURM_JOB_ID}+"*)"
fi
echo "JOBLOG_PATH ${JOBLOG_PATH}"

mkdir -p "${HOME}/joblatest" || :
ln -srfT "${JOBLOG_PATH}" "${HOME}/joblatest/start" || :

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
    ln -srfT "${JOBLOG_PATH}" "${HOME}/joblatest/fail" || :
}
trap 'err $LINENO' ERR

on_exit() {
  if [[ $? -eq 0 ]]; then
    ln -srfT "${JOBLOG_PATH}" "${HOME}/joblatest/succeed" || :
  fi
  ln -srfT "${JOBLOG_PATH}" "${HOME}/joblatest/finish" || :
}
trap on_exit EXIT
