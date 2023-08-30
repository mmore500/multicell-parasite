#!/bin/bash

#==============================================================================
# host ancestors
#==============================================================================

# provlogs for these sequences: https://osf.io/3ynf8

# andn-andn-log3aq-logic-3aq-log3bz-logic-3bz
HOST_SEQ_A="ycdBCiEdimFjfCDaknmsAjemEEcgccgssmhEEcsdseDcAcBcggclEEcDEgcvrsAmlzessjhcdcggkhamtmciEEvjDdhjidzoAyndvmEdbgznjDmcjohohooayaxdyalbcekzebjcogEtjgjacblDvubADnslyyocgsAcjCbobffhmvnnAdbDfkmxcagBFfndytqhutjdzfdjsnflfoqCwcvhsjcvbmlsqcjrgyiDivvnFhrArcsmifbClvluDqmCBbtiDhiEfACcarpEczijdljujACbfzuDEFyaqqekizDosbbzjgmpczypqvcrGxab"

# parasites never established in this host population
# log3aq-logic-3aq-log3bz-logic-3bz-log3by-logic-3by
# "ycduGinaxcevduorEubkrghBuyjBpaopciAebcvcBcoCDpcojdhhAjyhbDaelaECcrxdEcpDddogcDxbgeEsggdyiAdieDfpjsockmyzatmeBhAovcjEcjocDsdejcnisAcvxcijsAcdmsgyofFkuAcedyChFdAaCgFsAzszdchEcykBzbocntuhdkieclbnbqckfygnFposvfquiozrgFBcvmvvrdvokwbndcacockdkDgrgqiDcazcErucguxcgEkmBBEkmlomECglFFdzmmvyuzDndbCEeljmlgzlFjevcyCdckkCdlypqvbrGxab"

# didn't choose because all logic
# log3ar-logic-3ar-log3ah-logic-3ah-log3bo-logic-3bo/
# "ycdADatzDzDbBBDpzcECBkdydzDnzgiivmFdBEafminvbpdkbmzgzFkcBjvmpaioraBEchDFzlEbcgEcbDDgcDbfCkfDykfrytpotBaEcsfdeezDFhhfbongFdvmypCnAddFfgDtojsoAcyckyvCsCEvtjjCokFubzaAbiezvhfyBiACaochsrboxcEodDlhcbyfCzsBcibmqqlpdEgclrbnslgCgacAallcmErcAygeiFyhicdqvbFDfbhvzehbCdedEvpgjoACqsFcmfcFEpccbwbclEsnieiEmanzzhEajbkjFzlAdcypqvcrGxab"

# parasites never established in this host population
# log3ax-logic-3ax-log3ci-logic-3ci-log3ah-logic-3ah
# "ycdAocmefhicwdBcwciaagDauEcubpcsulcbjAhccgdiFcxcikbmtloyAcBvvqjvycFjmbfkvgzveEwcclbCotggcipDyEgzcgcgcumcCaiEEncgEiokBomcFmympksFCagtaailmfvCbAchojstfzszmnfszFgcwcDaygkdctwoAcespCmCdufzAxbwcnhcAlkylEmltDmclDbrusvaCFjdomEFgEiklokgzcfemmhknomribbfdFmhzAdFzyEoCmrkbhkjsFrAobgraCcgueuioEzrtuamEBjedalhymbfibdgDbEggiypqvcrGxab"

# log3bo-logic-3bo-log3ci-logic-3ci-log3ax-logic-3ax
HOST_SEQ_B="ycdAoavjxcjeovlCbmgbsnchiukDhjfbjoyCtsmotdDCCEkDdhclbmjglbjlEmexduCDaBmsygldnbvgoceDkjeAECcEcDchdgcCijwbAvEgcnoEccAcDtsaqBgclDEcCneEiribevfFhsziAcvsueiaoykwbuglmilzttbeAocvskEaoivebcldbeCFbiogBxdomhdcgfghjgEjvnoqvcAcDgcvtoogEogdohgnccoiCflEdovzDgvneClvDneyynynzydhFeCezillbkdqlfvrFdqosAovczrjEmfccsgipdcCkqFwcDypqvcrGxab"

# didn't choose because of orn overlap
# log3by-logic-3by-orn-orn-log3ba-logic-3ba
# "ycdAoafjkclEkxcjhcdallEcjgyvnfyfEggbEnvrhfukuBEvhvpDAoukonmdbwbqrmomegkyiCiDciCkqEjEiCgFsDjAFEjDieqvcFahtiubfvmaEEcbFgrllphswdicpccDkdpvqzmBCodwbjlckEcbclxcComBFCFgCggcxbgckcahhqgcDdjDcsjbjnicncoEgcvFtzcDgbuyqelbdAjfhgcEnEdFzdcoohnhdmaAgimqzajnqEdofbvftlFskAfyzsnvBftzCwclgisDgibbeaukBddEuCFhzygDeepdbrrirkyahzypqvbrGxab"

# orn-orn-log3ag-logic-3ag-log3bo-logic-3bo
HOST_SEQ_C="ycdAnyDdsAggeztrndzcvDauFEcEFiccgeoasirnDcoxcCuCbFddscbgcbccgEDtrcesdbzddtbcDgctDryddashoaDcirqubBcCxcdalzccoorbbbmxblEcCgcDchDaAbomaEdfyDmobnvrhzysingkDtscnAzcDwcEmmyfzkAcEslehEFnmDgvycmvbstenkvtdEdhhnCdyFsokfjeDDdcjefEfzihjboFqaeihacetiFdevBCghgnhrFzFldFlftdeBhFzFEAhhclsaFCjyutudhciokjeEvktqiaEhoFlvfzEznjzvypqvbrGxab"

# nand-nand-log3ah-logic-3ah-log3bz-logic-3bz
HOST_SEQ_D="ycdAivDauEslvbcdguFurkDaEEcDsccqgkcFhFbvCtzorgodFDalEcbscFsCgcDbddrFsDcAxcxcdgcigiobtgpEyzlcbfginkdbAfmFtzcAcEjnzjBCgBsAflhsgBcBcBgldtEtermAzFdrlzllipztoscoDhscfjcpfAneqzzCzFvCcgApgDdFBosjlimcorCreFfnchjcmzmBdqlfCiECCfzimDzzFCFqycmlcbemziatmdygFBdgEklozEalvzfdlgguqDcBcuueAllxbbobuiChDbdzFrgmpctBgazEAavojkfFihypqvbrGxab"

HOST_SEQS="${HOST_SEQ_A} ${HOST_SEQ_B} ${HOST_SEQ_C} ${HOST_SEQ_D}"
echo "HOST_SEQS ${HOST_SEQS}"

NUM_HOST_SEQS="$(echo "${HOST_SEQS}" | wc -w)"
echo "NUM_HOST_SEQS ${NUM_HOST_SEQS}"
#______________________________________________________________________________

#==============================================================================
# configurable parameters
#==============================================================================
export AVIDA="${AVIDA:-./avida}"
echo "AVIDA ${AVIDA}"

echo "pre EPOCH_ ${EPOCH_:-} EPOCH_COUNTER ${EPOCH_COUNTER:-} EPOCH ${EPOCH:-}"
export EPOCH_="${EPOCH_:-${EPOCH_COUNTER:-${EPOCH:-0}}}"
echo "EPOCH_ ${EPOCH_}"

export REPLICATE="${REPLICATE:-0}"
echo "REPLICATE ${REPLICATE}"

export WORLD_X="${WORLD_X:-35}"
echo "WORLD_X ${WORLD_X}"

export WORLD_Y="${WORLD_Y:-700}"
echo "WORLD_Y ${WORLD_Y}"

export WORLD_SIZE="$((WORLD_X * WORLD_Y))"
echo "WORLD_SIZE ${WORLD_SIZE}"

export NUM_DEMES="${NUM_DEMES:-20}"
echo "NUM_DEMES ${NUM_DEMES}"

export NUM_CELLS_PER_DEME="$((WORLD_SIZE / NUM_DEMES))"
echo "NUM_CELLS_PER_DEME ${NUM_CELLS_PER_DEME}"

export RANDOM_SEED="${RANDOM_SEED:-1}"
echo "RANDOM_SEED ${RANDOM_SEED}"

export NUM_UPDATES_INTRO_SMEAR="${NUM_UPDATES_INTRO_SMEAR:-1000}"
echo "NUM_UPDATES_INTRO_SMEAR ${NUM_UPDATES_INTRO_SMEAR}"

echo "TREATMENT ${TREATMENT}"

echo "enating treatment"
case "${TREATMENT}" in
  *evohost*)
    echo "evohost case"
    evohost=1
    evoeco=1
    export GERMLINE_COPY_MUT="${GERMLINE_COPY_MUT:-0.0075}"
  ;;&
  *ecohost*)
    echo "ecohost case"
    evoeco=1
    if ((${evohost:-0})); then echo "clashing treatment ${TREATMENT}"; exit 1; fi
    export GERMLINE_COPY_MUT=0

  ;;&
  *monohost*)
    echo "monohost case"
    monohost=1
    monopoly=1
    host_seq_idx="$(( REPLICATE % NUM_HOST_SEQS ))"
    host_seq_arr=($HOST_SEQS)
    export HOST_SEQS="${host_seq_arr["${host_seq_idx}"]}"
    export NUM_HOST_SEQS=1
    export NUM_DEME_PARTITIONS="${NUM_DEME_PARTITIONS:-1}"
  ;;&
  *polyhost*)
    monopoly=1
    echo "polyhost case"
    export NUM_DEME_PARTITIONS="${NUM_DEME_PARTITIONS:-4}"
    if ((${monohost:-0})); then echo "clashing treatment ${TREATMENT}"; exit 1; fi
    # nop
  ;;&
esac

# make sure both categories set
if ! ((${evoeco:-0})); then
  echo "bad treatment ${TREATMENT}, missing evoeco"
  exit 1
fi
if ! ((${monopoly:-0})); then
  echo "bad treatment ${TREATMENT}, missing monopoly"
  exti 1
fi

echo "GERMLINE_COPY_MUT ${GERMLINE_COPY_MUT}"
echo "HOST_SEQS ${HOST_SEQS}"
echo "NUM_DEME_PARTITIONS ${NUM_DEME_PARTITIONS}"
echo "NUM_HOST_SEQS ${NUM_HOST_SEQS}"

export DEMES_PARTITION_INTERVAL="$(( NUM_DEMES / NUM_DEME_PARTITIONS ))"
echo "DEMES_PARTITION_INTERVAL ${DEMES_PARTITION_INTERVAL}"

#______________________________________________________________________________


#==============================================================================
# avida.cfg
#==============================================================================
cat << EOF > "avida.cfg"
# Let's output a bit about the threads and parasites to stdout
VERBOSITY 3
# We use a bigger world than default
WORLD_X ${WORLD_X}
WORLD_Y ${WORLD_Y}
NUM_DEMES ${NUM_DEMES}
RANDOM_SEED ${RANDOM_SEED}



# DEME CONFIGURATION
#------------------------------------------------------------------------------

# Deme seeding method.
# 0 = Maintain old consistency
# 1 = New method using genotypes
DEMES_SEED_METHOD 0  # this doesn't matter for DEMES_USE_GERMLINE 1

# Number of organisms in a deme to trigger its replication (0 = OFF).
DEMES_REPLICATE_ORGS ${NUM_CELLS_PER_DEME}

# Deme divide method.
# Only works with DEMES_SEED_METHOD 1
# 0 = Replace source and target demes
# 1 = Replace target deme, reset source deme to founders
# 2 = Replace target deme, leave source deme unchanged
# 3 = Replace the target deme, and reset the number of resources consumed by the source deme.
# 4 = Replace the target deme,  reset the number of resources consumed by the source deme, and kill the germ line organisms of the source deme
DEMES_DIVIDE_METHOD 0

# divide hosts into separate subpopulations of five deme slots
DEMES_PARTITION_INTERVAL ${DEMES_PARTITION_INTERVAL}

# Should demes use a distinct germline?
# 0: No
# 1: Traditional germ lines
# 2: Genotype tracking
# 3: Organism flagging germline
DEMES_USE_GERMLINE 0

# Give empty demes preference as targets of deme replication?
DEMES_PREFER_EMPTY 1

# Reset resources in demes on replication?
# 0 = reset both demes
# 1 = reset target deme
# 2 = deme resources remain unchanged
DEMES_RESET_RESOURCES 2

# Number of offspring produced by a deme to trigger its replication.
# 0 = OFF
DEMES_REPLICATE_BIRTHS 0

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
DEMES_MIGRATION_METHOD 4  # necessary for parasite migration

# Probability of a parasite migrating to a different deme
# NOTE: only works with DEMES_MIGRATION_METHOD 4
DEMES_PARASITE_MIGRATION_RATE 0.2

# Probability of an offspring being born in a different deme.
DEMES_MIGRATION_RATE 0.0

MIGRATION_FILE migration.mat

# Log deme replications?
LOG_DEMES_REPLICATE 1
# Log injection of organisms.  0/1 (off/on)
LOG_INJECT 1


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

# should be redundant with disabling indel mutations, but
# parasites are somehow figuring out how to shrink anyways
# (likely due to bug in Avida :/)
# note: hosts have a larger genome size of 240 :)
MIN_GENOME_SIZE 80

# Substitution rate (per copy)
# We assign mtuation rates independently for hosts/parasites
COPY_MUT_PROB 0
# Insertion rate (per copy)
COPY_INS_PROB 0
# Deletion rate (per copy)
COPY_DEL_PROB 0
# Uniform mutation probability (per copy)
# Randomly apply insertion, deletion or substition mutation
COPY_UNIFORM_PROB 0
# Slip rate (per copy)
COPY_SLIP_PROB 0

# Substitution rate (per site, applied on divide)
DIV_MUT_PROB 0.0
# Insertion rate (per site, applied on divide)
DIV_INS_PROB 0.0
# Deletion rate (per site, applied on divide)
DIV_DEL_PROB 0.0
# Uniform mutation probability (per site, applied on divide)\n- Randomly apply insertion, deletion or point mutation
DIV_UNIFORM_PROB 0.0
# Slip rate (per site, applied on divide)
DIV_SLIP_PROB 0.0

# Substitution rate (max one, per divide
DIVIDE_MUT_PROB 0
# Insertion rate (max one, per divide)
DIVIDE_INS_PROB 0
# Deletion rate (max one, per divide)
DIVIDE_DEL_PROB 0

# Substitution rate (per site, applied on inject)
INJECT_MUT_PROB 0.005625
# Insertion rate (per site, applied on inject)
INJECT_INS_PROB 0.0
# Deletion rate (per site, applied on inject)
INJECT_DEL_PROB 0.0

# Prob. of copy mutations during germline replication
GERMLINE_COPY_MUT ${GERMLINE_COPY_MUT}
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
# migration.mat
#==============================================================================

echo "NUM_DEMES ${NUM_DEMES}"

python3 - << EOF
import numpy as np
num_demes = ${NUM_DEMES}
migration_mat = np.ones((num_demes, num_demes), dtype=int)
assert num_demes % 2 == 0

# disabled resevoir population logic
# i.e.,
# to
# r  r  t  t
# 1, 1, 1, 1  # from resevoir
# 1, 1, 1, 1  # from resevoir
# 0, 0, 1, 1  # from target population
# 0, 0, 1, 1  # from target population
# migration_mat[num_demes//2:,:num_demes//2] = 0
# assert migration_mat.sum().sum() == 3 * num_demes * num_demes // 4

np.savetxt('migration.mat', migration_mat, delimiter=",")
EOF
#______________________________________________________________________________


#==============================================================================
# environment.cfg
#==============================================================================
cat << 'EOF' > "environment.cfg"
RESOURCE resECHO:inflow=125:outflow=0.10
# disable host task rewards to avoid weirdness due to having "fast" and
# "slow" hosts at the same time

REACTION NAND nand process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
REACTION NOT not process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
REACTION ORN orn process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
REACTION LOG3BO logic_3BO process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
REACTION AND and process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
REACTION LOG3CI logic_3CI process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
REACTION ANDN andn process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
REACTION LOG3BZ logic_3BZ process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
REACTION LOG3AG logic_3AG process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
REACTION OR or process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
REACTION LOG3CP logic_3CP process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
REACTION LOG3BY logic_3BY process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
REACTION NOR nor process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
REACTION LOG3BS logic_3BS process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
REACTION LOG3BA logic_3BA process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
REACTION LOG3CJ logic_3CJ process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
REACTION LOG3AH logic_3AH process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
REACTION LOG3AQ logic_3AQ process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
REACTION LOG3CN logic_3CN process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
REACTION LOG3CB logic_3CB process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
REACTION LOG3AX logic_3AX process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
REACTION LOG3AR logic_3AR process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
REACTION LOG3AO logic_3AO process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
REACTION LOG3CH logic_3CH process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
REACTION LOG3CC logic_3CC process:resource=resECHO:value=0.0:type=add:frac=1.0:min=0:max=1:  requisite:reaction_max_count=1
EOF
#______________________________________________________________________________

#==============================================================================
# events.cfg
#==============================================================================
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

# need to prevent extinction abort on startup
$(
  if [ "${EPOCH_}" -ne 0 ]; then
    echo "i LoadPopulation host-parasite-smt.spop"
  else
    echo "i InjectSequence ${HOST_SEQS%% *} 0"
    for ((deme=0; deme<${NUM_DEMES}; deme++)); do
      host_org_idx="$((deme / DEMES_PARTITION_INTERVAL))"
      host_org_seq="$(echo ${HOST_SEQS} | cut -d " " -f "$((host_org_idx + 1))")"
      smear_delay="$(( (NUM_UPDATES_INTRO_SMEAR * deme) / NUM_DEMES))"
      target_cell_idx="$((deme * NUM_CELLS_PER_DEME))"
      echo "u ${smear_delay} InjectSequence ${host_org_seq} ${target_cell_idx}"
    done
  fi
)


# Let the hosts grow a bit, then inject parasites
$(
  if [ "${EPOCH_}" -eq 0 ]; then
  echo "u 2000:1 InjectParasite parasite-smt.org ABB 0 ${WORLD_SIZE} 2 1"
  else
  echo "u 0:1 InjectParasite parasite-smt.org ABB 0 ${WORLD_SIZE} 2 1"
  fi
)

u 0:100 PrintParasiteData ParasiteData.dat
u 0:100 PrintCountData
u 0:100 PrintDemeOrgGermlineSequestration

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
u 5000 PrintMigrationData
u 5000 SavePopulation

u 5000 Exit
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

"${AVIDA}" -c avida.cfg -r  # review config settings
"${AVIDA}" -c avida.cfg

unset EPOCH_
echo "unset EPOCH_ ${EPOCH_:-}"
