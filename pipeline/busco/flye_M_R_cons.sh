#!/bin/bash -l
#SBATCH -p batch,intel --nodes 1 --ntasks 32 --mem 128G --out logs/busco_flye_M_R8_cons.%A.log -J bMR8cons

# for augustus training
#export AUGUSTUS_CONFIG_PATH=/bigdata/stajichlab/shared/pkg/augustus/3.3/config
# set to a local dir to avoid permission issues and pollution in global
export AUGUSTUS_CONFIG_PATH=$(realpath lib/augustus/3.3/config)

CPU=${SLURM_CPUS_ON_NODE}

if [ ! $CPU ]; then
     CPU=2
fi
export NUMEXPR_MAX_THREADS=$CPU

LINEAGE=fungi_odb10
OUTFOLDER=BUSCO
mkdir -p $OUTFOLDER
SEED_SPECIES=massospora_cicadina_rs
ROUND=1
BASE=flye_M_R8_Cons${ROUND}
GENOMEFILE=$(realpath asm/consensus_bbmap/flye_5FC_medaka_R8/Masso_flye_5FC_M_R8.bbcons_round${ROUND}.fasta)

module load busco/5.2.2
busco -m genome -l $LINEAGE -c $CPU -o ${BASE} --out_path ${OUTFOLDER} --offline --augustus_species $SEED_SPECIES \
	  --in $GENOMEFILE --download_path $BUSCO_LINEAGES 
