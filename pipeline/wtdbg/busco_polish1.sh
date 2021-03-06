#!/bin/bash -l
#SBATCH --nodes 1 --ntasks 96 -p short -C ryzen --mem 128G --out logs/busco.%A.log -J busco

# for augustus training
#export AUGUSTUS_CONFIG_PATH=/bigdata/stajichlab/shared/pkg/augustus/3.3/config
# set to a local dir to avoid permission issues and pollution in global
export AUGUSTUS_CONFIG_PATH=$(realpath lib/augustus/3.3/config)

CPU=${SLURM_CPUS_ON_NODE}

if [ ! $CPU ]; then
     CPU=2
fi

LINEAGE=fungi_odb10
OUTFOLDER=BUSCO
mkdir -p $OUTFOLDER
SEED_SPECIES=entomophthora_muscae_ucb
GENOMEFILE=$(realpath asm/wtdbg2_5FC/Masso_5FC.polish1.fa)
BASE=wtdbg_polish_round1

#if [ -d "$OUTFOLDER/${BASE}" ];  then
#	    echo "Already have run $NAME in folder busco - do you need to delete it to rerun?"
#	    exit
#else
	    module load busco/5.1.2
	    busco -m genome -l $LINEAGE -c $CPU -o ${BASE} --out_path ${OUTFOLDER} --offline --augustus_species $SEED_SPECIES \
	  --in $GENOMEFILE --download_path $BUSCO_LINEAGES --restart
#fi
