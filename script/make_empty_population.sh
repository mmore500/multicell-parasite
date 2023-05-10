#!/bin/bash

set -e

source "$(readlink -f "$(dirname "$0")")/../pipeline/snippets/install_avida.sh"

#==============================================================================
# avida.cfg
#==============================================================================
cat << 'EOF' > "avida.cfg"
WORLD_X 60
WORLD_Y 60
NUM_DEMES 36

RANDOM_SEED 1

#Parasites use the TransSMT simulated hardware, which is setup in this weird way
#include INST_SET=instset-transsmt.cfg
EOF

#==============================================================================
# environment.cfg
#==============================================================================
cat << 'EOF' > "environment.cfg"
# intentionally empty
EOF

#==============================================================================
# events.cfg
#==============================================================================
cat << 'EOF' > "events.cfg"
u begin SavePopulation
u begin Exit
EOF

#==============================================================================
# instset-transsmt.cfg
#==============================================================================
cat << 'EOF' > "instset-transsmt.cfg"
INSTSET transsmt:hw_type=2

INST Nop-A
INST Nop-B
INST Nop-C
INST Nop-D
INST Val-Shift-R
INST Val-Shift-L
INST Val-Nand
INST Val-Add
INST Val-Sub
INST Val-Mult
INST Val-Div
INST Val-Mod
INST Val-Inc
INST Val-Dec
INST SetMemory
INST Inst-Read
INST Inst-Write
INST If-Equal
INST If-Not-Equal
INST If-Less
INST If-Greater
INST Head-Push
INST Head-Pop
INST Head-Move
INST Search
INST Push-Next
INST Push-Prev
INST Push-Comp
INST Val-Delete
INST Val-Copy
INST IO
INST Inject
INST Divide-Erase
EOF
#______________________________________________________________________________


"${AVIDA:-./avida}"

tree .

cp "data/detail--1.spop" "smt-empty.spop"

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

artifact_path = "smt-empty.spop"
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
