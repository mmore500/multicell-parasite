#!/bin/bash

export STAGE="$(echo "$0" | python3 -m keyname.cli extract stage)"
echo "STAGE ${STAGE}"

source "$(dirname "$0")/snippets/setup_instrumentation.sh"

cd "$(dirname "$0")"

RUNMODE="${1}"
echo "RUNMODE ${RUNMODE}"

REVISION="$(git rev-parse --short HEAD)"
echo "REVISION ${REVISION}"

BATCH="date=$(date +%Y-%m-%d)+time=$(date +%H-%M-%S)+revision=${REVISION}+uuid=$(uuidgen)"
echo "BATCH ${BATCH}"

STAGE_PATH="${HOME}/scratch/multicell-parasite/data/runmode=${RUNMODE}/stage=${STAGE}+what=collate_phylogenies/"
echo "STAGE_PATH ${STAGE_PATH}"

export BATCH_PATH="${STAGE_PATH}/batches/${BATCH}/"
echo "BATCH_PATH ${BATCH_PATH}"

# create data directory
for try in {0..9}; do
  mkdir -p "${BATCH_PATH}" && break
  echo "mkdir -p ${BATCH_PATH} failed (try ${try})"
  SLEEP_DURATION="$((RANDOM % 10 + 1))"
  echo "sleeping ${SLEEP_DURATION} then retrying"
  sleep "${SLEEP_DURATION}"
done

# symlink BATCH to STAGE/latest
for try in {0..9}; do
  ln -srfT "${BATCH_PATH}" "${STAGE_PATH}/latest" && break
  echo "ln -srfT ${BATCH_PATH} ${STAGE_PATH}/latest failed (try ${try})"
  echo "removing ${STAGE_PATH}/latest"
  rm -rf "${STAGE_PATH}/latest"
  SLEEP_DURATION="$((RANDOM % 10 + 1))"
  echo "sleeping ${SLEEP_DURATION} then retrying"
  sleep "${SLEEP_DURATION}"
done

source snippets/setup_production_dependencies.sh

echo "PWD ${PWD}"

DATA_PATH="${HOME}/scratch/multicell-parasite/data/runmode=${RUNMODE}/"
echo "DATA_PATH ${DATA_PATH}"

# provlog
python3 - << EOF
import glob
import re

import multiprocess as mp
from keyname import keyname as kn
from tqdm import tqdm


provlog_paths = [*glob.glob(
    "${DATA_PATH}/stage=201+what=run_paraevo_treatrepl/treatment=*/alph*replicate*/alph*epoch*/latest/**/provlog.yaml",
    recursive=True,
)]

pool = mp.Pool()
file_contents = []

def read_file(path):
    with open(path, 'r') as file:
        return file.read()

with tqdm(total=len(provlog_paths)) as pbar:
    for result in pool.imap_unordered(read_file, provlog_paths):
        file_contents.append(result)
        pbar.update()

pool.close()
pool.join()

# Concatenate the file contents and write to destination file
with open("${BATCH_PATH}/provlog.yaml", "w") as dest_file:
    dest_file.write("".join(file_contents))

EOF
echo "provlog concatenated"

cat << EOF >> "${BATCH_PATH}/provlog.yaml"
-
  a: $(basename "${BATCH_PATH}.provlog.yaml")
  batch: ${BATCH}
  stage: ${STAGE}
  date: $(date --iso-8601=seconds)
  hostname: $(hostname)
  path: $(realpath ${BATCH_PATH})
  revision: ${REVISION}
  runmode: ${RUNMODE}
  user: $(whoami)
  uuid: $(uuidgen)
  slurm_job_id: ${SLURM_JOB_ID-none}
  batch_path: $(readlink -f "${BATCH_PATH}")
EOF
echo "provlog appended"

# deduplicate provlog file
# add trailing whitespace to lines that aren't just -
# deduplicate records separated by -\n
# strip trailing whitespace
# drop extra -\n added to end
# uses inode trick to read/write from same file safely
# https://serverfault.com/a/557566
{ rm -f "${BATCH_PATH}/provlog.yaml" && sed '/.-/ s/\$/ /' | awk 'BEGIN{RS="-\n"; ORS=RS} !a[$0]++' - | sed 's/[ \t]*\$//' | head -c -2 > "${BATCH_PATH}/provlog.yaml"; } < "${BATCH_PATH}/provlog.yaml"
echo "provlog deduplicated"


# actual data
echo "compiling collated data..."
python3 - << EOF
import glob
import multiprocessing as mp
import re

from hstrat import _auxiliary_lib as hstrat_auxlib
from keyname import keyname as kn
import numpy as np
import pandas as pd
from tqdm import tqdm
import traceback


from AvidaScripts.GenericScripts.GenomeManipulation import (
    GenomeManipulator,
    make_named_instset_path,
    get_named_instset_content,
)
from AvidaScripts.GenericScripts.PhenotypeAssessment import (
    assess_phenotypes,
    assess_parasite_phenotypes,
    get_named_environment_content,
    summarize_mutational_neighborhood_phenotypes,
)
from AvidaScripts.GenericScripts.PopulationManipulation import (
    extract_dominant_taxon,
    load_population_dataframe,
    stitch_population_phylogenies,
)
from AvidaScripts.GenericScripts.MutationalNeighborhood import (
    get_onestep_pointmut_neighborhood,
    sample_twostep_pointmuts,
)


def process_one_path(path: str) -> pd.DataFrame:
    attrs = kn.unpack(path.replace("/", "+"))
    meta = {
        key: attrs[key]
        for key in (
            "replicate",
            "stage",
            "treatment",
        )
    }
    meta["run_uid"] = kn.pack(
        {
            key: meta[key]
            for key in (
                "replicate",
                "treatment"
            )
        },
    )

    pop_paths = [
        path
        for path in glob.glob(f"{path}/alph*epoch*/latest/data/detail*.spop")
        if int(kn.unpack(path.replace("/", "+"))["epoch"]) < 95
    ]
    pop_paths.sort(
        key=lambda path: int(kn.unpack(path.replace("/", "+"))["epoch"]),
    )

    pop_dfs = map(load_population_dataframe, pop_paths)

    stitched_df = stitch_population_phylogenies(
        pop_dfs,
        mutate = True,
    ).drop(
      [
        "Gestation (CPU) Cycle Offsets",
        "Lineage Label",
        "Genome Sequence",
        "Inst Set Name",
        "Source Args",
        "index",
      ],
      axis=1,
      errors="ignore",
    )
    # stitched_df["origin_time"] = (
    #   stitched_df["Update Born"]
    #   + stitched_df["epoch"] * 5001
    # )
    # there appear to be chronological inconsistencies w/ raw Avida data
    # so, granularize origin_time to epoch
    stitched_df["origin_time"] = stitched_df["epoch"]
    assert hstrat_auxlib.alifestd_validate(stitched_df), 'hstrat_auxlib.alifestd_validate(stitched_df)'
    assert hstrat_auxlib.alifestd_is_chronologically_ordered(stitched_df), 'hstrat_auxlib.alifestd_is_chronologically_ordered(stitched_df)'

    # environment_content = get_named_environment_content("top25")
    # instset_content = get_named_instset_content("transsmt")
    #
    # para_assessed_df = assess_parasite_phenotypes(
    #     set(
    #       stitched_df.loc[stitched_df["role"] == "parasite", "Genome Sequence"],
    #     ),
    #     environment_content,
    #     instset_content,
    # )
    # para_assessed_df["role"] = "parasite"
    # host_assessed_df = assess_phenotypes(
    #     set(stitched_df.loc[stitched_df["role"] == "host", "Genome Sequence"]),
    #     environment_content,
    #     instset_content,
    # )
    # host_assessed_df["role"] = "host"
    #
    # assessed_df = pd.concat([para_assessed_df, host_assessed_df], axis=0)
    #
    # complete_df = stitched_df.merge(
    #     assessed_df, on=["role", "Genome Sequence"], how="left"
    # )

    transformed = []
    for role, group in stitched_df.groupby("role"):
      if role == "host":
        continue
      df = group.reset_index()
      assert hstrat_auxlib.alifestd_validate(df), 'hstrat_auxlib.alifestd_validate(df)'
      assert hstrat_auxlib.alifestd_is_chronologically_ordered(df), 'hstrat_auxlib.alifestd_is_chronologically_ordered(df)'
      df = hstrat_auxlib.alifestd_join_roots(df, mutate=True)
      assert hstrat_auxlib.alifestd_validate(df), 'hstrat_auxlib.alifestd_validate(df)'
      assert hstrat_auxlib.alifestd_is_chronologically_ordered(df), 'hstrat_auxlib.alifestd_is_chronologically_ordered(df)'
      df = hstrat_auxlib.alifestd_topological_sort(df, mutate=True)
      assert hstrat_auxlib.alifestd_validate(df), 'hstrat_auxlib.alifestd_validate(df)'
      assert hstrat_auxlib.alifestd_is_chronologically_ordered(df), 'hstrat_auxlib.alifestd_is_chronologically_ordered(df)'
      df = hstrat_auxlib.alifestd_to_working_format(df, mutate=True)
      assert hstrat_auxlib.alifestd_is_chronologically_ordered(df), 'hstrat_auxlib.alifestd_is_chronologically_ordered(df)'
      df = hstrat_auxlib.alifestd_mark_ot_mrca_asexual(
        df, mutate=True, progress_wrap=tqdm
      )
      assert hstrat_auxlib.alifestd_is_chronologically_ordered(df), 'hstrat_auxlib.alifestd_is_chronologically_ordered(df)'
      df = hstrat_auxlib.alifestd_coarsen_mask(
        df,
        df["Number of currently living organisms"].astype(bool),
        mutate=True,
        progress_wrap=tqdm,
      )
      assert hstrat_auxlib.alifestd_is_chronologically_ordered(df), 'hstrat_auxlib.alifestd_is_chronologically_ordered(df)'
      transformed.append(df)

    print("agg")
    df = hstrat_auxlib.alifestd_aggregate_phylogenies(
      transformed, mutate=True
    )
    assert df["id"].is_unique, 'df["id"].is_unique'
    assert hstrat_auxlib.alifestd_validate(df), 'hstrat_auxlib.alifestd_validate(df)'
    assert hstrat_auxlib.alifestd_is_chronologically_ordered(df), 'hstrat_auxlib.alifestd_is_chronologically_ordered(df)'
    del transformed
    del stitched_df

    # coarsen to demes instead of cells
    # Explode the "Occupied Cell IDs" column
    df["Occupied Cell IDs"] = df["Occupied Cell IDs"].str.split(",")
    exploded = df.explode("Occupied Cell IDs")

    # Convert 'Occupied Cell IDs' to int and calculate the 'Deme ID'
    deme_size = 625
    exploded["Occupied Cell IDs"] = exploded["Occupied Cell IDs"].astype("int")
    exploded["Deme ID"] = (
      exploded["Occupied Cell IDs"] // deme_size
    ).astype("int")

    # Count duplicates and store the count in 'Num Cells' column
    num_cells = exploded.groupby(
      ["Deme ID", "id"],
    )["id"].transform(len)  # need a column to do Series transform
    assert len(num_cells) == len(exploded), 'len(num_cells) == len(exploded)'
    exploded["Num Cells"] = num_cells

    # Deduplicate based on 'Deme ID'
    deme_deduplicated = exploded.drop_duplicates(
      subset=["Deme ID", "id"],
      keep="first",
    )
    del exploded

    # arbitrarily resolve taxa split into different demes
    siblings = deme_deduplicated.duplicated("id", keep="first")
    num_siblings = siblings.sum()
    deme_deduplicated.loc[siblings, "id"] = (
      np.arange(num_siblings)
      + deme_deduplicated["id"].max() + 1  # ensure no clash with existing ids
    )
    id_deduplicated = deme_deduplicated
    del deme_deduplicated
    assert id_deduplicated["id"].is_unique, 'id_deduplicated["id"].is_unique'

    # need to update ancestor_list; if original deme was root,
    # then id pointed to self but now it points to sibling deme
    ancestor_list = hstrat_auxlib.alifestd_make_ancestor_list_col(
        id_deduplicated["id"], id_deduplicated["ancestor_id"]
    )
    id_deduplicated["ancestor_list"] = ancestor_list

    df = id_deduplicated
    del id_deduplicated
    assert hstrat_auxlib.alifestd_validate(df), 'hstrat_auxlib.alifestd_validate(df)'
    assert hstrat_auxlib.alifestd_is_chronologically_ordered(df), 'hstrat_auxlib.alifestd_is_chronologically_ordered(df)'
    for key, value in meta.items():
        df[key] = value

    return df


def try_process_one_path(path: str) -> pd.DataFrame:
    error = None
    for attempt in range(8):
        try:
            return process_one_path(path)
        except (pd.errors.ParserError, ValueError) as e:
            error = e
            continue

    print(path)
    traceback.print_exception(error)
    print()
    return pd.DataFrame()

spop_paths = [*glob.glob(
    "${DATA_PATH}/stage=201+what=run_paraevo_treatrepl/treatment=*/alph*replicate*/",
    recursive=True,
)]

print(f"processing {len(spop_paths)} spop paths...")

pool = mp.Pool(40)
dataframes = []
with tqdm(total=len(spop_paths)) as pbar:
    for result in pool.imap_unordered(try_process_one_path, spop_paths):
        dataframes.append(result)  # Append the returned DataFrame to the list
        pbar.update()

print("concatenating master dataframe")
master_df = pd.concat(
    dataframes,
    ignore_index=True,
)
print("master dataframe concatenated")

for treat, group in tqdm(master_df.groupby("treatment")):
    outpath = f"${BATCH_PATH}/a=phylogeny+what=concat+treatment={treat}+ext=.pqt"
    group.reset_index().to_parquet(
        outpath,
        compression="snappy",
        engine="pyarrow",  # fastparquet fails with overflowerror
        index=False,
    )
    print(f"{outpath} saved")

EOF

echo "fin"
