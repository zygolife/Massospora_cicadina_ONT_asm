#!/usr/bin/bash
#SBATCH -p gpu -n 1 -n 16 --mem 128gb --out logs/flye_medaka_stitchGPU.%A.log  --gres=gpu:1 --time 12:00:00 

module unload miniconda2
module unload miniconda3
module load medaka/1.5.0-gpu
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi

READS=input/guppy6/5FC.guppy6_0_1.fastq.gz
OUTDIR=asm/medaka/flye_5FC_round1
DRAFT=asm/flye_5FC/assembly.fasta
TMPSPLIT=$OUTDIR/split_cons

if [ ! -s $OUTDIR/polished.assembly.fasta ]; then
	time medaka stitch --threads $CPU $TMPSPLIT/*.hdf $DRAFT $OUTDIR/polished.assembly.GPU.fasta
fi

