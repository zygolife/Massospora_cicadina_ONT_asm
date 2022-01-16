#!/usr/bin/bash
#SBATCH -p intel --mem 512gb --out logs/AAFTF_pilon.%A.log -n 32 -N 1 -J AAFTF_pilon

hostname
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi

module load AAFTF
module load pilon
module load java/13
module load workspace/scratch
MEM=512
DRAFT=asm/medaka/consensus_racon1/consensus.fasta
LEFT=input/Massospora_2019-06_R1.fq.gz
RIGHT=input/Massospora_2019-06_R2.fq.gz
PILON=asm/pilon/medaka_6FC/Massospora_cicadina.pilon.fasta
mkdir -p asm/pilon/

if [ ! -f $PILON ]; then
	AAFTF pilon -i $DRAFT -o $PILON -c $CPU --left $LEFT  --right $RIGHT  --mem $MEM --tmpdir $SCRATCH
fi
