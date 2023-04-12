#!/bin/bash


#==============================================================================
# avida.cfg
#==============================================================================
cat << 'EOF' > "avida.cfg"
#Let's output a bit about the threads and parasites to stdout
VERBOSITY 3
#We use a bigger world than default
WORLD_X 40
WORLD_Y 400
NUM_DEMES 10

DEMES_SEED_METHOD 1
DEMES_DIVIDE_METHOD 2
DEMES_USE_GERMLINE 2
DEMES_PREFER_EMPTY 1
DEMES_RESET_RESOURCES 2

DEMES_REPLICATE_BIRTHS 100000000
DEMES_MAX_BIRTHS 0
DEMES_PREFER_EMPTY 1
DEMES_MIGRATION_METHOD 4
DEMES_PARASITE_MIGRATION_RATE 0.002
DEMES_MIGRATION_RATE 0.0

MIGRATION_FILE migration.mat


#We assign mtuation rates independently for hosts/parasites
COPY_MUT_PROB 0

DIV_MUT_PROB 0.001000
DIV_INS_PROB 0.0
DIV_DEL_PROB 0.0

DIVIDE_INS_PROB 0
DIVIDE_DEL_PROB 0

INJECT_MUT_PROB 0.00#5625
INJECT_INS_PROB 0.00#0625
INJECT_DEL_PROB 0.00#0625


GERMLINE_COPY_MUT 0.0                # Prob. of copy mutations during germline replication
GERMLINE_INS_MUT 0.0
GERMLINE_DEL_MUT 0.0
#Make birth non-spatial

BIRTH_METHOD 6 #random within deme
PREFER_EMPTY 0

#Hosts get to live a bit longer than usual
AGE_LIMIT 30

#Keep genomes from programatically creating their own variation
#...because it's complicated enough as is
STERILIZE_UNSTABLE 1

#Don't reset host thread upon infection
INJECT_METHOD 1

#Parasite Specfic Settings
INFECTION_MECHANISM 1
REQUIRE_SINGLE_REACTION 1
PARASITE_VIRULENCE 0.85
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
