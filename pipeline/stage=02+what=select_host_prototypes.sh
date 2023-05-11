#!/bin/bash

cd "$(dirname "$0")"

source snippets/setup_instrumentation.sh

RUNMODE="${1}"
echo "RUNMODE ${RUNMODE}"

REVISION="$(git rev-parse --short HEAD)"
echo "REVISION ${REVISION}"

EXTRACTED_HOSTS_PATH="${HOME}/scratch/multicell-parasite/data/runmode=${RUNMODE}/stage=01+what=extract_host_prototypes/latest/"
echo "EXTRACTED_HOSTS_PATH ${EXTRACTED_HOSTS_PATH}"

python3 - << EOF
import glob
import os
import shutil

def copy_file(src, dst):
  print(f"copying {src} -> {dst}")

  # Create necessary directories if they don't exist
  os.makedirs(os.path.dirname(dst), exist_ok=True)

  # Copy the file
  shutil.copytree(src, dst)

attempts = {
  "nand-nand" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "nand-nand" | wc -l),
  "not-not" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "not-not" | wc -l),
  "orn-orn" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "orn-orn" | wc -l),
  "log3bo-logic-3bo" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "log3bo-logic-3bo" | wc -l),
  "and-and" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "and-and" | wc -l),
  "log3ci-logic-3ci" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "log3ci-logic-3ci" | wc -l),
  "andn-andn" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "andn-andn" | wc -l),
  "log3bz-logic-3bz" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "log3bz-logic-3bz" | wc -l),
  "log3ag-logic-3ag" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "log3ag-logic-3ag" | wc -l),
  "or-or" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "or-or" | wc -l),
  "log3cp-logic-3cp" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "log3cp-logic-3cp" | wc -l),
  "log3by-logic-3by" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "log3by-logic-3by" | wc -l),
  "nor-nor" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "nor-nor" | wc -l),
  "log3bs-logic-3bs" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "log3bs-logic-3bs" | wc -l),
  "log3ba-logic-3ba" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "log3ba-logic-3ba" | wc -l),
  "log3cj-logic-3cj" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "log3cj-logic-3cj" | wc -l),
  "log3ah-logic-3ah" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "log3ah-logic-3ah" | wc -l),
  "log3aq-logic-3aq" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "log3aq-logic-3aq" | wc -l),
  "log3cn-logic-3cn" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "log3cn-logic-3cn" | wc -l),
  "log3cb-logic-3cb" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "log3cb-logic-3cb" | wc -l),
  "log3ax-logic-3ax" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "log3ax-logic-3ax" | wc -l),
  "log3ar-logic-3ar" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "log3ar-logic-3ar" | wc -l),
  "log3ao-logic-3ao" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "log3ao-logic-3ao" | wc -l),
  "log3ch-logic-3ch" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "log3ch-logic-3ch" | wc -l),
  "log3cc-logic-3cc" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=00+what=evolve_host_prototypes/" | grep "log3cc-logic-3cc" | wc -l),
}
print("attempt counts", attempts)

triple_threats = {
  "nand-nand" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "nand-nand" | wc -l),
  "not-not" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "not-not" | wc -l),
  "orn-orn" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "orn-orn" | wc -l),
  "log3bo-logic-3bo" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "log3bo-logic-3bo" | wc -l),
  "and-and" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "and-and" | wc -l),
  "log3ci-logic-3ci" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "log3ci-logic-3ci" | wc -l),
  "andn-andn" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "andn-andn" | wc -l),
  "log3bz-logic-3bz" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "log3bz-logic-3bz" | wc -l),
  "log3ag-logic-3ag" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "log3ag-logic-3ag" | wc -l),
  "or-or" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "or-or" | wc -l),
  "log3cp-logic-3cp" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "log3cp-logic-3cp" | wc -l),
  "log3by-logic-3by" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "log3by-logic-3by" | wc -l),
  "nor-nor" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "nor-nor" | wc -l),
  "log3bs-logic-3bs" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "log3bs-logic-3bs" | wc -l),
  "log3ba-logic-3ba" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "log3ba-logic-3ba" | wc -l),
  "log3cj-logic-3cj" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "log3cj-logic-3cj" | wc -l),
  "log3ah-logic-3ah" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "log3ah-logic-3ah" | wc -l),
  "log3aq-logic-3aq" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "log3aq-logic-3aq" | wc -l),
  "log3cn-logic-3cn" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "log3cn-logic-3cn" | wc -l),
  "log3cb-logic-3cb" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "log3cb-logic-3cb" | wc -l),
  "log3ax-logic-3ax" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "log3ax-logic-3ax" | wc -l),
  "log3ar-logic-3ar" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "log3ar-logic-3ar" | wc -l),
  "log3ao-logic-3ao" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "log3ao-logic-3ao" | wc -l),
  "log3ch-logic-3ch" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "log3ch-logic-3ch" | wc -l),
  "log3cc-logic-3cc" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep "log3cc-logic-3cc" | wc -l),
}
print("triple threat counts", triple_threats)

fraction_successes = {key: triple_threats[key] / attempts[key] for key in attempts if attempts[key]}
print("fraction successes", fraction_successes)

remaining = {
  "nand-nand" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "nand-nand" | wc -l),
  "not-not" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "not-not" | wc -l),
  "orn-orn" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "orn-orn" | wc -l),
  "log3bo-logic-3bo" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "log3bo-logic-3bo" | wc -l),
  "and-and" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "and-and" | wc -l),
  "log3ci-logic-3ci" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "log3ci-logic-3ci" | wc -l),
  "andn-andn" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "andn-andn" | wc -l),
  "log3bz-logic-3bz" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "log3bz-logic-3bz" | wc -l),
  "log3ag-logic-3ag" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "log3ag-logic-3ag" | wc -l),
  "or-or" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "or-or" | wc -l),
  "log3cp-logic-3cp" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "log3cp-logic-3cp" | wc -l),
  "log3by-logic-3by" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "log3by-logic-3by" | wc -l),
  "nor-nor" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "nor-nor" | wc -l),
  "log3bs-logic-3bs" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "log3bs-logic-3bs" | wc -l),
  "log3ba-logic-3ba" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "log3ba-logic-3ba" | wc -l),
  "log3cj-logic-3cj" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "log3cj-logic-3cj" | wc -l),
  "log3ah-logic-3ah" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "log3ah-logic-3ah" | wc -l),
  "log3aq-logic-3aq" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "log3aq-logic-3aq" | wc -l),
  "log3cn-logic-3cn" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "log3cn-logic-3cn" | wc -l),
  "log3cb-logic-3cb" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "log3cb-logic-3cb" | wc -l),
  "log3ax-logic-3ax" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "log3ax-logic-3ax" | wc -l),
  "log3ar-logic-3ar" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "log3ar-logic-3ar" | wc -l),
  "log3ao-logic-3ao" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "log3ao-logic-3ao" | wc -l),
  "log3ch-logic-3ch" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "log3ch-logic-3ch" | wc -l),
  "log3cc-logic-3cc" : $(ls "${HOME}/scratch/multicell-parasite/data/runmode=production/stage=01+what=extract_host_prototypes/" | grep -v log3cj-logic | grep -v log3bs-logic-3bs | grep -v log3cc-logic | grep -v or-or | grep -v nor-nor | grep "log3cc-logic-3cc" | wc -l),
}
print("remaining after drop", remaining)

dropped_tasks = [k for k, v in fraction_successes.items() if v < 0.33]
print("dropped_tasks", dropped_tasks)

for attempt_path in glob.glob("${EXTRACTED_HOSTS_PATH}/*"):
  print(attempt_path)
  if not any(dropped_task in attempt_path for dropped_task in dropped_tasks):
    copy_file(attempt_path, attempt_path.replace(
      "stage=01+what=extract_host_prototypes",
      "stage=02+what=select_host_prototypes",
    ))
EOF

OUTPUT_PATH="${HOME}/scratch/multicell-parasite/data/runmode=production/stage=02+what=select_host_prototypes/latest/"
echo "OUTPUT_PATH ${OUTPUT_PATH}"

OUTPUT_ORG_GLOB="${OUTPUT_PATH}/**/host_prototype.org"
echo "OUTPUT_ORG_GLOB ${OUTPUT_ORG_GLOB}"

for output_org in ${OUTPUT_ORG_GLOB}; do

# create provlog
cat << EOF >> "${output_org}.provlog.yaml"
-
  a: host_prototype.org.provlog.yaml
  stage: 2
  date: $(date --iso-8601=seconds)
  hostname: $(hostname)
  path: ${output_org}.provlog.yaml
  revision: ${REVISION}
  runmode: ${RUNMODE}
  user: $(whoami)
  uuid: $(uuidgen)
  shasum256: $(shasum -a256 ${output_org} | cut -d " " -f1)
  slurm_job_id: ${SLURM_JOB_ID-none}
EOF

done
