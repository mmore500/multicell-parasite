#!/bin/bash

# REVISION shouldd be set in script sourcing this one
echo "REVISION ${REVISION}"

module purge || :
module load \
  GCCcore/11.3.0 \
  binutils/2.38 \
  ccache/3.3.3 \
  CMake/3.23.1 \
  git/2.36.0-nodocs \
  Python/3.10.4 \
  || :

ln -s "${HOME}/scratch" "/mnt/scratch/${USER}/" || :
TMPDIR="${HOME}/scratch/tmp"
mkdir -p "${TMPDIR}"

VENV_CACHE_PATH="/${TMPDIR}/venv-${REVISION}"
echo "VENV_CACHE_PATH ${VENV_CACHE_PATH}"

GITDIR="$(git rev-parse --show-toplevel)"  # absolute path
echo "GITDIR ${GITDIR}"
git -C "${GITDIR}" diff --quiet HEAD -- "${GITDIR}/requirements.txt" || {
  echo "dirty ${GITDIR}/requirements.txt"; exit 1
}


if test -d "${VENV_CACHE_PATH}" && [[ -n "${REVISION}" ]]
then


echo "venv cache available at ${VENV_CACHE_PATH}"
VENV_PATH="${VENV_CACHE_PATH}"
source "${VENV_PATH}/bin/activate"

else

echo "no eligible venv cache available at ${VENV_CACHE_PATH}"
echo "maybe revision isn't set?"
VENV_PATH="$(mktemp -d)"  # uses $TMPDIR
echo "VENV_PATH ${VENV_PATH}"

for try in {0..9}; do
  rm -rf "${VENV_PATH}"  \
  && python3 -m venv "${VENV_PATH}"  \
  && echo "venv created"  \
    \
  && source "${VENV_PATH}/bin/activate"  \
    \
  && python3 -m pip install -r "https://raw.githubusercontent.com/mmore500/multicell-parasite/${REVISION}/requirements.txt" \
  && break \
  || echo "venv setup failed (try ${try})"

  SLEEP_DURATION="$((RANDOM % 10 + 1))"
  echo "sleeping ${SLEEP_DURATION} then retrying"
  sleep "${SLEEP_DURATION}"
done

echo "setting venv cache at ${VENV_CACHE_PATH}"
ln -s "${VENV_PATH}" "${VENV_CACHE_PATH}" || :

unset TMPDIR  # prevent subsequent tempfiles from ending up in scratch

fi
