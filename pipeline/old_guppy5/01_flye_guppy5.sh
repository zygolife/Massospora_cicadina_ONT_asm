#!/usr/bin/bash
#SBATCH -p intel -N 1 -n 32 --out logs/flye.%A.log --mem 128gb

module load Flye/2.8.3
module load minimap2/2.21
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi
mkdir -p asm
flye --nano-raw input/Massospora_RS.guppy_5.0.11.fq.gz --threads $CPU --out-dir asm/flye_RS --genome-size 1000m --meta
