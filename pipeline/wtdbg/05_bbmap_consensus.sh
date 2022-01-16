#!/usr/bin/bash -l
#SBATCH -N 1 -n 96 -p short --mem 256gb -C xeon --out logs/wtdbg_bbmap_consensus.%A.log
# -N 1 -n 48 -p batch,intel --mem 128gb --out logs/wtdbg_bbmap_consensus.%A.log
module load BBMap
module load samtools
module load bcftools
module load workspace/scratch
MEM=256g
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi
DRAFT=$(realpath asm/racon/wtdbg_round1/racon.fasta)
INFASTQPAIRED=$(realpath input/Massospora_201906.ecc.fa.gz)
INFASTQUNPAIR=$(realpath input/Massospora_201906.unmerged_ecc.fa.gz)
OUTDIR=asm/consensus_bbmap/wtdbg_5FC_round1
PAIRBAM=paired-mapped_round1.bam
UNPAIRBAM=unpaired-mapped_round1.bam
BAM=mapped_round1.bam
mkdir -p $OUTDIR
OUTDIR=$(realpath $OUTDIR)

for ROUND in $(seq 5)
do
  VCF=$OUTDIR/illumina_variants.round${ROUND}.vcf
  CONS=$OUTDIR/Masso_5FC.consensus_round${ROUND}.fasta
  echo "Running Round $$ROUND to produced $CONS"
  if [ ! -s $CONS ]; then
      if [ ! -f $VCF.gz ]; then
	  pushd $SCRATCH
	  if [ ! -d 'ref' ]; then
	      bbmap.sh ref=$DRAFT threads=$CPU
	  fi
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
	  bcftools consensus -f $DRAFT $VCF.gz -o $CONS
	  module load AAFTF
	  AAFTF assess -i $CONS -r $(echo -n $CONS | perl -p -e 's/.fasta$/.stats.txt/')
	  module unload AAFTF
      fi
      popd
      exit # don't allow this to run multiple rounds when we are running on short queue
  fi
  DRAFT=$CONS
done
