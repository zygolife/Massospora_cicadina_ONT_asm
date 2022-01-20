#!/usr/bin/bash
#SBATCH -N 1 -n 128 -p short --mem 256gb --out logs/racon_flye.%A.log -C ryzen

module load minimap2
module load racon
module load workspace/scratch

CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi
N=8
if [ ! -z "$1" ]; then
	N=$1
fi

DRAFT=asm/medaka/flye_5FC_round1/polished.assembly.fasta
READS=input/guppy6/5FC.guppy6_0_1.fastq.gz
OUTDIR=asm/racon/flye_5FC_medaka
mkdir -p $OUTDIR

for ROUND in $(seq $N)
do
    ALN=$SCRATCH/Masso.round${ROUND}.paf.gz
    TARGET=$OUTDIR/racon.round${ROUND}.fasta
    if [ ! -s $TARGET ]; then
	if [[ ! -f $ALN || $DRAFT -nt $ALN ]]; then
	    minimap2 -t $CPU -x map-ont $DRAFT $READS | pigz -c > $ALN
	fi
	# add gpu options?
	if [ ! -f $TARGET ]; then
	    racon -m 8 -x -6 -g -8 -w 500 -t $CPU $READS $ALN $DRAFT > $TARGET
	fi
    fi
    DRAFT=$TARGET
done
