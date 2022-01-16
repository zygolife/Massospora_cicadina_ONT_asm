#!/usr/bin/bash
#SBATCH -N 1 -n 96 -p short --mem 256gb --out logs/wtdbg2_polish.%A.log -C ryzen

module load minimap2
module load wtdbg2
module load workspace/scratch
module load samtools

CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi
FQ1=input/Massospora_2019-06_R1.fq.gz
FQ2=input/Massospora_2019-06_R2.fq.gz
DRAFT=asm/wtdbg2_5FC/Masso_5FC.ctg.fa
DBG=$SCRATCH/Masso_5FC.dbg.fa
POLISH1=asm/wtdbg2_5FC/Masso_5FC.polish1.fa
READS=input/guppy6/5FC.guppy6_0_1.fastq.gz
OUTDIR=asm/wtdbg2_5FC
ALN=$OUTDIR/Masso_5FC.round1.bam

#RACON1=$OUTDIR/racon.fasta
mkdir -p $OUTDIR
if [[ ! -f $ALN || $DRAFT -nt $ALN ]]; then
	minimap2 -t $CPU -ax map-ont $DRAFT $READS | pigz -c > $ALN
fi
if [ ! -f $POLISH1 ]; then
	samtools view -F0x900 $ALN | wtpoa-cns -t $CPU -d $DRAFT -i - -fo $DBG
	bwa index $DBG
	bwa mem -t $CPU $DBG $FQ1 $FQ2 | samtools sort -O SAM | wtpoa-cns -t $CPU -x sam-sr -d $DBG -i - -fo $POLISH1
fi
