#!/bin/bash

set -e

source "$(readlink -f "$(dirname "$0")")/../pipeline/snippets/install_avida.sh"

"$(readlink -f "$(dirname "$0")")/../cfg/a=make-host-smt-population+what=config-and-run.sh"

tree .

cp "data/detail--1.spop" "host-smt-ancestral.spop"

# create provlog
PYSCRIPT=$(cat << HEREDOC
import hashlib
import logging

from retry import retry


logging.basicConfig(
    format="\n%(asctime)s %(levelname)-8s %(message)s\n",
    level=logging.INFO,
    datefmt=">>> %Y-%m-%d %H:%M:%S",
)

def open_(*args, **kwargs):
  return open(*args, **kwargs)
open_retry = retry(
  tries=10, delay=1, max_delay=10, backoff=2, jitter=(0, 4), logger=logging,
)(open_)

artifact_path = "host-smt-ancestral.spop"
provlog_path = f"{artifact_path}.provlog.yaml"

@retry(
  tries=10, delay=1, max_delay=10, backoff=2, jitter=(0, 4), logger=logging,
)
def do_save():
  with open_retry(provlog_path, "w+") as provlog_file:
    provlog_file.write(
f"""-
  a: {provlog_path}
  artifact: {artifact_path}
  artifact_sha256: {
    hashlib.sha256(open_retry(artifact_path, 'rb').read()).hexdigest()
  }
  date: $(date --iso-8601=seconds)
  hostname: $(hostname)
  revision: $(git rev-parse HEAD)
  revision_avida: ${AVIDA_REVISION}
  user: $(whoami)
  uuid: $(uuidgen)
  script: $(readlink -f "$0")
  slurm_job_id: ${SLURM_JOB_ID-none}
  pwd: $(pwd)
"""
    )

do_save()

logging.info(f"wrote provlog to {provlog_path}")

HEREDOC
)
python3 -c "${PYSCRIPT}"
