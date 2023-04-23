#!/bin/bash


#==============================================================================
# avida.cfg
#==============================================================================
cat << 'EOF' > "avida.cfg"
# Let's output a bit about the threads and parasites to stdout
VERBOSITY 3
# We use a bigger world than default
WORLD_X 40
WORLD_Y 400
NUM_DEMES 10



# DEME CONFIGURATION
#------------------------------------------------------------------------------

# Deme seeding method.
# 0 = Maintain old consistency
# 1 = New method using genotypes
DEMES_SEED_METHOD 1

# Deme divide method.
# Only works with DEMES_SEED_METHOD 1
# 0 = Replace and target demes
# 1 = Replace target deme, reset source deme to founders
# 2 = Replace target deme, leave source deme unchanged
# 3 = Replace the target deme, and reset the number of resources consumed by the source deme.
# 4 = Replace the target deme,  reset the number of resources consumed by the source deme, and kill the germ line organisms of the source deme
DEMES_DIVIDE_METHOD 2

# Should demes use a distinct germline?
# 0: No
# 1: Traditional germ lines
# 2: Genotype tracking
# 3: Organism flagging germline
DEMES_USE_GERMLINE 2

# Give empty demes preference as targets of deme replication?
DEMES_PREFER_EMPTY 1

# Reset resources in demes on replication?
# 0 = reset both demes
# 1 = reset target deme
# 2 = deme resources remain unchanged
DEMES_RESET_RESOURCES 2

# Number of offspring produced by a deme to trigger its replication.
# 0 = OFF
DEMES_REPLICATE_BIRTHS 100000000

# Max number of births that can occur within a deme;
# used with birth-count replication
DEMES_MAX_BIRTHS 0

# Give empty demes preference as targets of deme replication?
DEMES_PREFER_EMPTY 1

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

# Make birth non-spatial
# Which organism should be replaced when a birth occurs?
# 0 = Random organism in neighborhood
# 1 = Oldest in neighborhood
# 2 = Largest Age/Merit in neighborhood
# 3 = None (use only empty cells in neighborhood)
# 4 = Random from population (Mass Action)
# 5 = Oldest in entire population
# 6 = Random within deme
# 7 = Organism faced by parent
# 8 = Next grid cell (id+1)
# 9 = Largest energy used in entire population
# 10 = Largest energy used in neighborhood
# 11 = Local neighborhood dispersal
# 12 = Kill offpsring after recording birth stats (for behavioral trials)
# 13 = Kill parent and offpsring (for behavioral trials)
BIRTH_METHOD 6 # random within deme
# Overide BIRTH_METHOD to preferentially choose empty cells for offsping?
PREFER_EMPTY 0

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

# Don't reset host thread upon infection
# What should happen to a parasite when it gives birth?
# 0 = Leave the parasite thread state untouched.
# 1 = Resets the state of the calling thread (for SMT parasites, this must be 1)
INJECT_METHOD 1

# 0: Infection always succeeds.
# 1: Infection succeeds if parasite matches at least one host task
# 2: Infection succeeds if parasite does NOT match at least one task
# 3: Parasite tasks must match host tasks exactly (Matching Alleles)
INFECTION_MECHANISM 1

# If set to 1, at least one reaction is required for a successful divide
REQUIRE_SINGLE_REACTION 1

# Infection causes host steralization and takes all cpu cycles
# (setting this to 1 will override inject_virulence)
INJECT_IS_VIRULENT 0

# The probabalistic percentage of cpu cycles allocated to the parasite instead of the host.
# Ensure INJECT_IS_VIRULENT is set to 0.
# This only works for single infection at the moment.
# Note that this should be set to a default even if virulence is evolving.
PARASITE_VIRULENCE 0.85

# Maximum number of Threads a CPU can spawn
MAX_CPU_THREADS 2

#Parasites use the TransSMT simulated hardware, which is setup in this weird way
#include INST_SET=instset-transsmt.cfg
EOF
#______________________________________________________________________________


#==============================================================================
# environment.cfg
#==============================================================================
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
#______________________________________________________________________________


#==============================================================================
# events.cfg
#==============================================================================
cat << 'EOF' > "events.cfg"
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

# Seed the population with a single organism
#u begin InjectAll filename=host-smt.org
#u 1 KillProb 1.0
u begin InjectModuloDemes host-smt.org 1


# Let the hosts grow a bit, then inject parasites
#u 4000 InjectParasite parasite-smt.org ABB 0 100
#u 4000 InjectParasite parasite-smt.org ABB 1600 1700
#u 4000 InjectParasite parasite-smt.org ABB 3200 3300
#u 4000 InjectParasite parasite-smt.org ABB 3200 3300
#u 4000 InjectParasite parasite-smt.org ABB 4800 4900
#u 4000 InjectParasite parasite-smt.org ABB 6400 6500
#u 4000 InjectParasite parasite-smt.org ABB 8000 8100
#u 4000 InjectParasite parasite-smt.org ABB 9600 9700
#u 4000 InjectParasite parasite-smt.org ABB 11200 11300
#u 4000 InjectParasite parasite-smt.org ABB 12800 12900
#u 4000 InjectParasite parasite-smt.org ABB 14400 14500

u 12000 SetConfig PARASITE_VIRULENCE 0
u 13000 SetConfig PARASITE_VIRULENCE 0.85

u 13000 InjectParasite parasite-smt.org ABB 0 100
u 13000 InjectParasite parasite-smt.org ABB 1600 1700
u 13000 InjectParasite parasite-smt.org ABB 3200 3300
u 13000 InjectParasite parasite-smt.org ABB 3200 3300
u 13000 InjectParasite parasite-smt.org ABB 4800 4900
u 13000 InjectParasite parasite-smt.org ABB 6400 6500
u 13000 InjectParasite parasite-smt.org ABB 8000 8100
u 13000 InjectParasite parasite-smt.org ABB 9600 9700
u 13000 InjectParasite parasite-smt.org ABB 11200 11300
u 13000 InjectParasite parasite-smt.org ABB 12800 12900
u 13000 InjectParasite parasite-smt.org ABB 14400 14500

u 20000 Exit

u 0:500:end PrintHostPhenotypeData
u 0:500:end PrintParasitePhenotypeData

u 10000:10000:end DumpHostGenotypeList
u 10000:10000:end DumpParasiteGenotypeList


u 0:200:end DumpHostTaskGrid
u 0:200:end DumpParasiteTaskGrid

u 0:200:end PrintHostTasksData
u 0:200:end PrintParasiteTasksData


u 0:100:end PrintParasiteData ParasiteData.dat

# Save info about they average genotypes
u 0:100:end PrintAverageData
u 0:100:end PrintCountData         # Count organisms, genotypes, species, etc.
u 0:100:end PrintTimeData          # Track time conversion (generations, etc.)
EOF
#______________________________________________________________________________


#==============================================================================
# host-smt.org
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

#==============================================================================
# migration.mat
#==============================================================================
cat << 'EOF' > "migration.mat"
1, 1, 1, 1, 1, 1, 1, 1, 1, 1
1, 1, 1, 1, 1, 1, 1, 1, 1, 1
1, 1, 1, 1, 1, 1, 1, 1, 1, 1
1, 1, 1, 1, 1, 1, 1, 1, 1, 1
1, 1, 1, 1, 1, 1, 1, 1, 1, 1
1, 1, 1, 1, 1, 1, 1, 1, 1, 1
1, 1, 1, 1, 1, 1, 1, 1, 1, 1
1, 1, 1, 1, 1, 1, 1, 1, 1, 1
1, 1, 1, 1, 1, 1, 1, 1, 1, 1
1, 1, 1, 1, 1, 1, 1, 1, 1, 1
EOF
#______________________________________________________________________________

#==============================================================================
# parasite-smt.org
#==============================================================================
cat << 'EOF' > "parasite-smt.org"
Search       #  1:  Find organism end.
Nop-C        #  2:  - Match CD:AB
Nop-D
Push-Prev    #  5:  Move end position to Stack-A
SetMemory    #  6:  Place FLOW-head in memory space for offspring
Nop-A
Head-Move    #  7:  Move Write head to flow head position
Nop-C        #  8:
Nop-C
Nop-C        #  8:
Nop-C      #  8:
Nop-C
Nop-C
IO
IO
IO
Nop-C
Nop-C        #  8:
Nop-C        #  8:
Nop-C        #  8:
Nop-C
Nop-C        #  8:
Nop-C
Nop-C        #  8:
Nop-C        #  8:
Nop-C
Nop-C        #  8:
Val-Nand
Nop-C        #  8:
Nop-C        #  8:
Nop-C        #  8:
Nop-C
Nop-C        #  8:
Nop-C #IO
Nop-C #IO
Nop-C      #  8:
Nop-C
Nop-C
Nop-C
Nop-C        #  8:
Nop-C        #  8:
Nop-C        #  8:
Nop-C        #  8:
Nop-C
Nop-C
Nop-C
IO
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C        #  8:
Nop-C
Nop-C        #  8:
Nop-C        #  8:
Nop-C
Nop-C
Nop-C
Nop-C
Nop-C        #  8:
Nop-C        #  8:
Nop-C
Nop-C        #  8:
Nop-C #Val-Nand
Nop-C
Search       #  9:  Drop flow head at start of copy loop
Inst-Read    # 10:
Inst-Write   # 11:
Head-Push    # 12:  Get current position of...
Nop-C        # 13:  - Read-Head
If-Equal     # 14:  Test if we are done copying...
Inject
Nop-A
Nop-D
Nop-D
Head-Move    # 16:  ...If not, continue with loop.
Nop-A        # 17:
Nop-B
EOF
#______________________________________________________________________________

./avida -c avida.cfg


# collate task profiles across updates
python3 - <<'EOF'
import glob
import re

import numpy as np
import pandas as pd


for target in "hosts", "parasite":
  task_filenames = glob.glob(
    f"data/grid_task_{target}.*.dat",
  )
  file_dfs = []
  for task_filename in task_filenames:
    print(f"handling {task_filename}")
    update = int(
      re.search(r"\d+", task_filename).group()
    )
    tasks_df = pd.read_csv(
      task_filename, sep=" ", header=None
    ).dropna(axis=1)

    occupancy = tasks_df.to_numpy().flatten() != -1

    tasks = tasks_df.to_numpy().flatten()
    tasks[~occupancy] = 0

    task_counts = np.array([
        int(val).bit_count()
        for val in tasks
    ])

    df = pd.DataFrame({
      "position" : [*range(len(occupancy))],
      "occupancy" : occupancy,
      "task bit field" : tasks,
      "task count" : task_counts,
      "update" : update,
    })

    for i in range(10):
        has_task = (tasks & (1 >> i)).astype(bool)
        df[f"has task {i}"] = has_task

    file_dfs.append(df)

  print(f"writing collated tasks to data/{target}_tasks.csv.gz")
  pd.concat(file_dfs).reset_index(drop=True).to_csv(
    f"data/{target}_tasks.csv.gz", index=False
  )

print("task collation complete")
EOF
