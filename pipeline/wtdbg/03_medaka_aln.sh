#!/usr/bin/bash -l
# -C xeon -p short -n 96 -N 1 --mem 256gb --out logs/medaka_aln.%A.log
#SBATCH -p stajichlab -n 32 -N 1 --mem 128gb --out logs/medaka_aln.%A.log

module unload miniconda2
module unload miniconda3
module load medaka/1.4.3

CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi

READS=input/guppy6/5FC.guppy6_0_1.fastq.gz
OUTDIR=asm/medaka/wtdbg_round1
DRAFT=asm/racon/wtdbg_round1/racon.fasta

mkdir -p $OUTDIR

if [ ! -f  $OUTDIR/calls_to_draft.bam ]; then
	mini_align -i ${READS} -r $DRAFT -m \
    -p $OUTDIR/calls_to_draft.bam -t $CPU 
fi
