#!/usr/bin/bash
#SBATCH -p short -C ryzen -N 1 -n 96--out logs/wtdbg2.%A.log --mem 384gb

module load wtdbg2/2.5
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi
OUTDIR=asm/wtdbg2_5FC
PREF=Masso_5FC
INPUT=input/guppy6/5FC.guppy6_0_1.fastq.gz
mkdir -p asm/wtdbg2_5FC
if [ ! -f $OUTDIR/$PREF.ctg.lay.gz ]; then
	wtdbg2 -x ont -g 1.1g -t $CPU -i $INPUT -fo $OUTDIR/$PREF
fi
if [ ! -f $OUTDIR/$PREF.ctg.fa ]; then
  wtpoa-cns -t $CPU -i $OUTDIR/$PREF.ctg.lay.gz -fo $OUTDIR/$PREF.ctg.fa
fi
