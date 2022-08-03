#!/usr/bin/bash
#SBATCH -N 1 -n 32 -p intel,batch  --mem 96gb --out logs/bwa_racon.%A.log

module load bwa
module load racon

CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi

DRAFT=asm/flye_6FC/assembly.fasta
READS=input/Masso_6FC.Nanopore.fastq.gz
ALN=asm/racon/round1/Masso_6FC.bwa_aln.sam.gz
RACON1=asm/racon/round1/racon.fasta
mkdir -p asm/racon/round1

if [ ! -f $DRAFT.bwt ]; then
	bwa index $DRAFT
fi
mkdir -p asm/racon_round1
if [[ ! -f $ALN || $DRAFT -nt $ALN ]]; then
	bwa mem -t $CPU -x ont2d $DRAFT $READS | pigz -c > $ALN
fi
# add gpu options?
if [ ! -f $RACON1 ]; then
	racon -m 8 -x -6 -g -8 -w 500 -t $CPU $READS $ALN $DRAFT > $RACON1
fi
