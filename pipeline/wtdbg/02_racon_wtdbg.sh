#!/usr/bin/bash
#SBATCH -N 1 -n 96 -p short --mem 256gb --out logs/racon.%A.log

module load minimap2
module load racon

CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi

DRAFT=asm/wtdbg2_5FC/Masso_5FC.ctg.fa
READS=input/guppy6/5FC.guppy6_0_1.fastq.gz
OUTDIR=asm/racon/wtdbg_round1
ALN=$OUTDIR/Masso.sam.gz
RACON1=$OUTDIR/racon.fasta
mkdir -p $OUTDIR
if [[ ! -f $ALN || $DRAFT -nt $ALN ]]; then
	minimap2 -t $CPU -ax map-ont $DRAFT $READS | pigz -c > $ALN
fi
# add gpu options?
if [ ! -f $RACON1 ]; then
	racon -m 8 -x -6 -g -8 -w 500 -t $CPU $READS $ALN $DRAFT > $RACON1
fi
