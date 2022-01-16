#!/usr/bin/bash
#SBATCH -C xeon -p short -n 64 -N 1 --mem 128gb --out logs/medaka_aln.%a.log

module unload miniconda2
module unload miniconda3
module load medaka/1.4.3
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi

BASECALLS=input/Masso_6FC.Nanopore.fastq.gz
DRAFT=asm/racon/round1/racon.fasta
OUTDIR=asm/medaka/consensus_racon1
mkdir -p $OUTDIR

if [ ! -f  $OUTDIR/calls_to_draft.bam ]; then
mini_align -i ${BASECALLS} -r $DRAFT -P -m \
    -p $OUTDIR/calls_to_draft.bam -t $CPU
fi

