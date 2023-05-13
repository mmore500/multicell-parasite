#!/bin/bash

set -e
set -o nounset
shopt -s globstar

export JOBSCRIPT_PATH="$0"
echo "JOBSCRIPT_PATH ${JOBSCRIPT_PATH}"
readlink -f "${JOBSCRIPT_PATH}"
export JOBSCRIPT_PATH="$(readlink -f "${JOBSCRIPT_PATH}")"
echo "JOBSCRIPT_PATH ${JOBSCRIPT_PATH}"

mkdir -p "${HOME}/jobscript" || :
cp "${JOBSCRIPT_PATH}" "${HOME}/jobscript/$(date '+%Y%m%d-%H%M')-${SLURM_JOB_ID:-none}.slurm.sh" || :

err() {
    echo "Error occurred:"
    awk 'NR>L-4 && NR<L+4 { printf "%-5d%3s%s\n",NR,(NR==L?">>>":""),$0 }' L="$1" "$0"
}
trap 'err $LINENO' ERR
