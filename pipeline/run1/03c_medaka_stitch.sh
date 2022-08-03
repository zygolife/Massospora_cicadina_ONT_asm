#!/usr/bin/bash
#SBATCH -n 1 -n 32 --mem 128gb --out logs/medaka_stitch.%A.log  -p intel,batch
module unload miniconda2
module unload miniconda3
module load medaka/1.4.3
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi
N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
    N=$1
    if [ ! $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi


BASECALLS=input/Masso_6FC.Nanopore.fastq.gz
DRAFT=asm/racon/round1/racon.fasta
OUTDIR=asm/medaka/consensus_racon1
TMPSPLIT=$OUTDIR/split_cons

if [ ! -s $OUTDIR/polished.assembly.fasta ]; then
	time medaka stitch --threads $CPU $TMPSPLIT/*.hdf $OUTDIR/polished.assembly.fasta
fi

