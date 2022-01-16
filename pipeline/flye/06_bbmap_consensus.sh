#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 96 -C xeon --mem 384gb --out logs/flye_bbmap_consensus.%A.log

module load BBMap
module load samtools
module load bcftools
module load workspace/scratch
MEM=384g
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi
DRAFT=$(realpath asm/racon/flye_5FC_round1/racon.fasta)
INFASTQPAIRED=$(realpath input/Massospora_201906.ecc.fa.gz)
INFASTQUNPAIR=$(realpath input/Massospora_201906.unmerged_ecc.fa.gz)
OUTDIR=asm/consensus_bbmap/flye_5FC_round1
PAIRBAM=paired-mapped_round1.bam
UNPAIRBAM=unpaired-mapped_round1.bam
BAM=mapped_round1.bam
mkdir -p $OUTDIR
OUTDIR=$(realpath $OUTDIR)

VCF=$OUTDIR/illumina_variants.vcf
CONS=$OUTDIR/Masso_5FC.consensus_round1.fasta

if [ ! -f $VCF.gz ]; then
  pushd $SCRATCH
  bbmap.sh ref=$DRAFT threads=$CPU
  bbmap.sh -Xmx$MEM -eoom usejni=t pigz=t threads=$CPU vslow=t in=$INFASTQPAIRED out=$PAIRBAM overwrite=t unpigz=f fastareadlen=600
  bbmap.sh -Xmx$MEM -eoom usejni=t pigz=t threads=$CPU vslow=t in=$INFASTQUNPAIR out=$UNPAIRBAM overwrite=t unpigz=f fastareadlen=600
  samtools merge --threads $CPU tmp_${BAM} $PAIRBAM $UNPAIRBAM
  samtools sort --threads $CPU -T $SCRATCH/flye5C -o $BAM tmp_${BAM}
  samtools index $BAM

  callvariants.sh -Xmx$MEM threads=$CPU ref=$DRAFT in=$BAM ploidy=1 vcf=$VCF minscore=20.0 overwrite=t

  # use bgzip and tabix to compress then index vcf file
  bgzip -f $VCF
  tabix -p vcf $VCF.gz
fi
if [ ! -f $CONS ]; then
  # use bcftools to get consensus sequence
  bcftools consensus -f $DRAFT $VCF -o $CONS
fi
