#!/usr/bin/bash -l
#SBATCH -N 1 -p batch,intel -n 48 --mem 192gb --out logs/flye_M_R8_bbmap_consensus.%A.log
module load BBMap
module load samtools
module load bcftools
module load workspace/scratch
MEM=256g
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi
N=1
if [ ! -z $1 ]; then
	N=$1
elif [ ! -z ${SLURM_ARRAY_TASK_ID} ]; then
	N=${SLURM_ARRAY_TASK_ID}
fi
DRAFT=$(realpath asm/racon/flye_5FC_medaka/racon.round8.fasta)
INFASTQUNPAIRED=$(realpath input/Massospora_201906.ecc.fa.gz)
INFASTQUNMERGEDF=$(realpath input/Massospora_201906.unmerged_ecc.R1.fa.gz)
INFASTQUNMERGEDR=$(realpath input/Massospora_201906.unmerged_ecc.R2.fa.gz)
OUTDIR=asm/consensus_bbmap/flye_5FC_medaka_R8
OUTDIR=$(realpath $OUTDIR)
mkdir -p $OUTDIR

ROUND=$N
MERGEDBAM=mergemapped_round${ROUND}.bam
UNMERGEDBAM=unmerged-mapped_round${ROUND}.bam
BAM=mapped_round${ROUND}.bam
VCF=$OUTDIR/illumina_variants.round${ROUND}.vcf
CONS=$OUTDIR/Masso_flye_5FC_M_R8.bbcons_round${ROUND}.fasta
echo "Running Round $ROUND to produced $CONS"
if [ ! -s $CONS ]; then
    if [ ! -f $VCF.gz ]; then
	pushd $SCRATCH
	if [ ! -d 'ref' ]; then
	    bbmap.sh -Xmx$MEM ref=$DRAFT threads=$CPU
	fi
	bbmap.sh -Xmx$MEM -eoom usejni=t pigz=t threads=$CPU vslow=t in=$INFASTQUNMERGEDF in2=$INFASTQUNMERGEDR out=$UNMERGEDBAM overwrite=t unpigz=f fastareadlen=600
	bbmap.sh -Xmx$MEM -eoom usejni=t pigz=t threads=$CPU vslow=t in=$INFASTQUNPAIRED out=$MERGEDBAM overwrite=t unpigz=f fastareadlen=600
	samtools merge --threads $CPU tmp_${BAM} $MERGED $UNMERGEDBAM
	samtools sort --threads $CPU -T $SCRATCH -o $BAM tmp_${BAM}
	samtools index $BAM
	if [ -f $BAM ]; then	
		callvariants.sh -Xmx$MEM threads=$CPU ref=$DRAFT in=$BAM ploidy=1 vcf=$VCF minscore=20.0 overwrite=t
		bgzip -f $VCF
		tabix -p vcf $VCF.gz
	fi
	popd
    fi
    if [ ! -f $CONS ]; then
	# use bcftools to get consensus sequence
	bcftools consensus -f $DRAFT $VCF.gz -o $CONS
	module load AAFTF
	AAFTF assess -i $CONS -r $(echo -n $CONS | perl -p -e 's/.fasta$/.stats.txt/')
	module unload AAFTF
    fi
fi
