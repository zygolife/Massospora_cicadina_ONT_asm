#!/usr/bin/bash
#SBATCH -p intel,batch -N 1 -n 48 --out logs/flye.%A.log --mem 384gb

module load Flye/2.9
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi
mkdir -p asm
flye --nano-raw input/guppy6/5FC.guppy6_0_1.fastq.gz --threads $CPU --out-dir asm/flye_5FC --genome-size 1100m --meta --resume
