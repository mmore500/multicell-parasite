#!/bin/bash


#==============================================================================
# avida.cfg
#==============================================================================
cat << 'EOF' > "avida.cfg"
VERBOSITY 3
WORLD_X 60
WORLD_Y 60
RANDOM_SEED ${RANDOM_SEED:-1}


# DEME CONFIGURATION
#------------------------------------------------------------------------------


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
u begin LoadPopulation host-smt.spop
u 5000 SavePopulation

u 5000 PrintHostPhenotypeData
u 5000 PrintParasitePhenotypeData

u 5000 DumpHostGenotypeList
u 5000 DumpParasiteGenotypeList

u 5000 DumpHostTaskGrid
u 5000 DumpParasiteTaskGrid

u 5000 PrintHostTasksData
u 5000 PrintParasiteTasksData

u 5000 PrintAverageData       # Save info about the average genotypes
u 5000 PrintCountData         # Count organisms, genotypes, species, etc.
u 5000 PrintTimeData          # Track time conversion (generations, etc.)

u 5000 Exit

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


${AVIDA:-./avida} -c avida.cfg
