#!/usr/bin/bash -l
#SBATCH -N 1 -p batch,intel -n 48 --mem 256gb --out logs/flye_M_R8_spades_Scaff.%A.log
module load SPAdes
module load workspace/scratch
MEM=256
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi
DRAFT=$(realpath asm/racon/flye_5FC_medaka/racon.round8.fasta)
INFASTQ=$(realpath input/Massospora_2019-06.fq.gz)
OUTDIR=asm/scaffold_shortread/flye_5FC_medaka_R8.spades2
mkdir -p $OUTDIR
OUTDIR=$(realpath $OUTDIR)
if [ ! -f $OUTDIR/scaffolds.fasta ]; then
	if [ -f $OUTDIR/params.txt ]; then
		spades.py --continue
	else
		spades.py -t $CPU --mem $MEM --pe-12 1 $INFASTQ --trusted-contigs $DRAFT -o $OUTDIR --only-assembler --careful
	fi
fi
if [ -f $OUTDIR/scaffolds.fasta ]; then
    module load AAFTF
    AAFTF assess -i $OUTDIR/scaffolds.fasta -r $OUTDIR/scaffolds.stats.txt
  fi
