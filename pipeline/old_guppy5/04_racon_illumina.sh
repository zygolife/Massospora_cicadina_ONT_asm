#!/usr/bin/bash
#SBATCH -N 1 -n 32 -p intel --mem 128gb --out logs/bwa_racon_illumina.%A.log

module load bwa
module load racon
hostname
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi

DRAFT=asm/medaka/consensus_racon1/consensus.fasta
READS=input/Massospora_2019-06.fastq.gz
ALN=asm/racon/illumina_medaka/Masso_illumina.bwa.sam.gz
RACON1=asm/racon/illumina_medaka/racon1.fasta
mkdir -p asm/racon/illumina_medaka

if [ ! -f $DRAFT.bwt ]; then
	bwa index $DRAFT
fi
mkdir -p asm/racon/illumina_medaka
if [[ ! -f $ALN || $DRAFT -nt $ALN ]]; then
	bwa mem -t $CPU -p $DRAFT $READS | pigz -c > $ALN
fi
# add gpu options?
if [ ! -f $RACON1 ]; then
	racon -m 8 -x -6 -g -8 -w 500 -t $CPU $READS $ALN $DRAFT > $RACON1
fi
