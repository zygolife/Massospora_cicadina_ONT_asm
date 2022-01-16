#!/usr/bin/bash
#SBATCH -N 1 -n 32 -p intel,batch  --mem 256gb --out logs/bwa_racon.%A.log

module load bwa
module load racon

CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi

DRAFT=asm/flye_RS/assembly.fasta
READS=input/Massospora_RS_CON.guppy_5.0.11.fq.gz
ALN=asm/racon/round1_RS/Masso_CON.bwa_aln.sam.gz
RACON1=asm/racon/round1_RS/racon.fasta
mkdir -p asm/racon/round1_RS

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
