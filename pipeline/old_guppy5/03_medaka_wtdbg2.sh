#!/usr/bin/bash
#SBATCH -p gpu -n 1 -n 24 --mem 300gb --out logs/medaka_wtdbg2.%A.log  --gres=gpu:1 --time 64:00:00
module unload miniconda2
module unload miniconda3
module load medaka/1.4.3-gpu
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi

BASECALLS=input/guppy6/5FC.guppy6_0_1.fastq.gz
DRAFT=asm/racon/wtdbg_round1/racon.fasta
OUTDIR=asm/medaka/consensus_wtdbg1
mkdir -p $OUTDIR
medaka_consensus -i ${BASECALLS} -d ${DRAFT} -o ${OUTDIR} -t $CPU  -m r941_min_high_g344 -b 100


