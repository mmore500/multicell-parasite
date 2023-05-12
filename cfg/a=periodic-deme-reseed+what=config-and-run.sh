#!/bin/bash


export NUM_DEMES="${NUM_DEMES:-36}"
echo "NUM_DEMES ${NUM_DEMES}"

export RANDOM_SEED="${RANDOM_SEED:-1}"
echo "RANDOM_SEED ${RANDOM_SEED}"

export WORLD_X="${WORLD_X:-60}"
echo "WORLD_X ${WORLD_X}"

export WORLD_Y="${WORLD_Y:-60}"
echo "WORLD_Y ${WORLD_Y}"

#==============================================================================
echo avida.cfg
#==============================================================================
cat << EOF > "avida.cfg"
VERBOSITY 3
WORLD_X ${WORLD_X}
WORLD_Y ${WORLD_Y}
RANDOM_SEED ${RANDOM_SEED}


# DEME CONFIGURATION
#------------------------------------------------------------------------------
NUM_DEMES ${NUM_DEMES}

# Deme seeding method.
# 0 = Maintain old consistency
# 1 = New method using genotypes
# DEMES_SEED_METHOD 1  # N/A

# Deme divide method.
# Only works with DEMES_SEED_METHOD 1
# 0 = Replace and target demes
# 1 = Replace target deme, reset source deme to founders
# 2 = Replace target deme, leave source deme unchanged
# 3 = Replace the target deme, and reset the number of resources consumed by the source deme.
# 4 = Replace the target deme,  reset the number of resources consumed by the source deme, and kill the germ line organisms of the source deme
# DEMES_DIVIDE_METHOD 2  # N/A

# Should demes use a distinct germline?
# 0: No
# 1: Traditional germ lines
# 2: Genotype tracking
# 3: Organism flagging germline
# DEMES_USE_GERMLINE 2  # N/A

# Give empty demes preference as targets of deme replication?
# DEMES_PREFER_EMPTY 1  # N/A

# Reset resources in demes on replication?
# 0 = reset both demes
# 1 = reset target deme
# 2 = deme resources remain unchanged
# DEMES_RESET_RESOURCES 2  # N/A

# Number of offspring produced by a deme to trigger its replication.
# 0 = OFF
DEMES_REPLICATE_BIRTHS 0

# Max number of births that can occur within a deme;
# used with birth-count replication
DEMES_MAX_BIRTHS 0

# Give empty demes preference as targets of deme replication?
# DEMES_PREFER_EMPTY 1  # N/A

# Which demes can an offspring land in when it migrates?
# 0 = Any other deme
# 1 = Eight neighboring demes
# 2 = Two adjacent demes in list
# 3 = Proportional based on the number of points
# 4 = Use the weight matrix specified in MIGRATION_FILE
DEMES_MIGRATION_METHOD 4

# Probability of a parasite migrating to a different deme
DEMES_PARASITE_MIGRATION_RATE 0.002

# Probability of an offspring being born in a different deme.
DEMES_MIGRATION_RATE 0.0

# NxN file that describes connectivity weights between demes
MIGRATION_FILE migration.mat


# Cell Configuration
#------------------------------------------------------------------------------

# Hosts get to live a bit longer than usual
# When should death by old age occur?
# When executed genome_length * AGE_LIMIT (+dev) instructions
AGE_LIMIT 30


# MUTATION CONFIGURATION
#------------------------------------------------------------------------------

# Substitution rate (per copy)
# We assign mtuation rates independently for hosts/parasites
COPY_MUT_PROB 0

# Substitution rate (per site, applied on divide)
DIV_MUT_PROB 0.001000
# Insertion rate (per site, applied on divide)
DIV_INS_PROB 0.0
# Deletion rate (per site, applied on divide)
DIV_DEL_PROB 0.0

# Insertion rate (max one, per divide)
DIVIDE_INS_PROB 0
# Deletion rate (max one, per divide)
DIVIDE_DEL_PROB 0

# Substitution rate (per site, applied on inject)
INJECT_MUT_PROB 0.00#5625
# Insertion rate (per site, applied on inject)
INJECT_INS_PROB 0.00#0625
# Deletion rate (per site, applied on inject)
INJECT_DEL_PROB 0.00#0625

# Prob. of copy mutations during germline replication
GERMLINE_COPY_MUT 0.0
# Prob. of insertion mutations during germline replication
GERMLINE_INS_MUT 0.0
# Prob. of deletion mutations during germline replication
GERMLINE_DEL_MUT 0.0

# Keep genomes from programatically creating their own variation
# ...because it's complicated enough as is
# Should genotypes that cannot replicate perfectly not be allowed to replicate?
STERILIZE_UNSTABLE 1



# PARASITE CONFIGURATION
#------------------------------------------------------------------------------

#include INST_SET=instset-transsmt.cfg
EOF
#______________________________________________________________________________


#==============================================================================
echo environment.cfg
#==============================================================================
if [ ! -f "environment.cfg" ]; then
  cat << 'EOF' > "environment.cfg"
RESOURCE  resECHO:inflow=125:outflow=0.10

REACTION  NOT  not   process:resource=resECHO:value=0.0:type=pow:frac=0.5:min=1:max=1:  requisite:reaction_max_count=1
REACTION  NAND nand  process:resource=resECHO:value=0.0:type=pow:frac=0.5:min=1:max=1:  requisite:reaction_max_count=1
REACTION  AND  and   process:resource=resECHO:value=0.0:type=pow:frac=0.5:min=1:max=1:  requisite:reaction_max_count=1
REACTION  ORN  orn   process:resource=resECHO:value=0.0:type=pow:frac=0.5:min=1:max=1:  requisite:reaction_max_count=1
REACTION  OR   or    process:resource=resECHO:value=0.0:type=pow:frac=0.5:min=1:max=1:  requisite:reaction_max_count=1
REACTION  ANDN andn  process:resource=resECHO:value=0.0:type=pow:frac=0.5:min=1:max=1:  requisite:reaction_max_count=1
REACTION  NOR  nor   process:resource=resECHO:value=0.0:type=pow:frac=0.5:min=1:max=1:  requisite:reaction_max_count=1
REACTION  XOR  xor   process:resource=resECHO:value=0.0:type=pow:frac=0.5:min=1:max=1:  requisite:reaction_max_count=1
REACTION  EQU  equ   process:resource=resECHO:value=0.0:type=pow:frac=0.5:min=1:max=1:  requisite:reaction_max_count=1

EOF
else
  echo "pre-existing environment.cfg detected"
  echo "config-and-run environment.cfg skipped"
fi
#______________________________________________________________________________


#==============================================================================
echo events.cfg
#==============================================================================
export DEME_RESEED_PERIOD="${DEME_RESEED_PERIOD:-50}"
echo "DEME_RESEED_PERIOD ${DEME_RESEED_PERIOD}"

export ANCESTRAL_HOST_ORG_PATHS="${ANCESTRAL_HOST_ORG_PATHS:-host-smt.org}"
echo "ANCESTRAL_HOST_ORG_PATHS ${ANCESTRAL_HOST_ORG_PATHS}"

export NUM_ANCESTRAL_HOST_ORG_PATHS="$(echo ANCESTRAL_HOST_ORG_PATHS | wc -w)"
echo "NUM_ANCESTRAL_HOST_ORG_PATHS ${NUM_ANCESTRAL_HOST_ORG_PATHS}"

echo "NUM_DEMES ${NUM_DEMES}"

export WORLD_SIZE="$((WORLD_X * WORLD_Y))"
echo "WORLD_SIZE ${WORLD_SIZE}"

cat << EOF > "events.cfg"
##############################################################################
#
# This is the setup file for the events system.  From here, you can
# configure any actions that you want to have happen during the course of
# an experiment, including setting the times for data collection.
#
# basic syntax: [trigger] [start:interval:stop] [action/event] [arguments...]
#
# This file is currently setup to record key information every 100 updates.
#
# For information on how to use this file, see:  doc/events.html
# For other sample event configurations, see:  support/config/
#
##############################################################################
i SetFracDemeTreatable 1.0

i LoadPopulation host-parasite-smt.spop

i KillDemePercent 1.0 0
i Inject ${ANCESTRAL_HOST_ORG_PATHS%% *} 0

$(
  for ((deme=0; deme<${NUM_DEMES}; deme++)); do
    host_org_idx="$((deme % NUM_ANCESTRAL_HOST_ORG_PATHS))"
    ancestral_host_org_path="$(echo ${ANCESTRAL_HOST_ORG_PATHS} | cut -d " " -f "$((host_org_idx + 1))")"
    reseed_period_offset="$(( deme ? DEME_RESEED_PERIOD * deme / NUM_DEMES : DEME_RESEED_PERIOD))"
    target_cell_idx="$(( deme * WORLD_SIZE / NUM_DEMES ))"
    echo "u ${reseed_period_offset}:${DEME_RESEED_PERIOD} KillDemePercent 1.0 ${deme}"
    echo "u ${reseed_period_offset}:${DEME_RESEED_PERIOD} Inject ${ancestral_host_org_path} ${target_cell_idx}"
  done
)

u 5000 InjectParasite parasite-smt.org ABB 0 10

u 5000 PrintHostPhenotypeData
u 5000 PrintParasitePhenotypeData

u 5000 DumpHostGenotypeList
u 5000 DumpParasiteGenotypeList

u 5000 DumpHostTaskGrid
u 5000 DumpParasiteTaskGrid

u 5000 PrintHostTasksData
u 5000 PrintParasiteTasksData

u 5000 PrintParasiteData ParasiteData.dat
u 5000 PrintAverageData       # Save info about the average genotypes
u 5000 PrintCountData         # Count organisms, genotypes, species, etc.
u 5000 PrintTimeData          # Track time conversion (generations, etc.)

u 5000 SavePopulation

u 5000 Exit

EOF
#______________________________________________________________________________


#==============================================================================
echo host-smt.org
#==============================================================================
cat << 'EOF' > "host-smt.org"
Search
Nop-C
Nop-D
Push-Prev
SetMemory
Nop-A
Nop-D
Nop-D
Head-Move
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
IO
IO
IO
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Val-Nand
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
IO
Nop-C
Nop-C
Nop-C
Nop-C
Val-Copy
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-D
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Head-Move
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Push-Prev
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
If-Greater
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Search
Inst-Read
Inst-Write
Head-Push
Nop-C
If-Equal
Divide-Erase
Head-Move
Nop-A
Nop-B
EOF
#______________________________________________________________________________

#==============================================================================
echo migration.mat
#==============================================================================

echo "NUM_DEMES ${NUM_DEMES}"

python3 - << EOF
import numpy as np
num_demes = ${NUM_DEMES}
migration_mat = np.ones((num_demes, num_demes), dtype=int)
assert num_demes % 2 == 0

# i.e.,
# to
# r  r  t  t
# 1, 1, 1, 1  # from resevoir
# 1, 1, 1, 1  # from resevoir
# 0, 0, 1, 1  # from target population
# 0, 0, 1, 1  # from target population

migration_mat[num_demes//2:,:num_demes//2] = 0
assert migration_mat.sum().sum() == 3 * num_demes * num_demes // 4

np.savetxt('migration.mat', migration_mat, delimiter=",")
EOF
#______________________________________________________________________________

#==============================================================================
echo instset-transsmt.cfg
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


${AVIDA:-./avida} -c avida.cfg