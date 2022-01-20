#!/usr/bin/bash -l
#SBATCH -C xeon -p short -n 96 -N 1 --mem 256gb --out logs/flye_medaka_aln.%A.log

module unload miniconda2
module unload miniconda3
module load medaka/1.5.0
module load workspace/scratch

CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi

READS=input/guppy6/5FC.guppy6_0_1.fastq.gz
OUTDIR=asm/medaka/flye_5FC_round1
DRAFT=asm/flye_5FC/assembly.fasta

mkdir -p $OUTDIR

if [ ! -f  $OUTDIR/calls_to_draft.bam ]; then
	mini_align -i ${READS} -r $DRAFT -m -p $SCRATCH/calls_to_draft -t $CPU
	rsync -av $SCRATCH/calls_to_draft* $OUTDIR/
fi
