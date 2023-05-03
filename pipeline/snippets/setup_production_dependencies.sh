#!/bin/bash

# REVISION shouldd be set in script sourcing this one
echo "REVISION ${REVISION}"

module purge || :
module load GCCcore/11.3.0 git/2.36.0-nodocs Python/3.10.4 || :

VENV_PATH="$(mktemp -d)"
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
