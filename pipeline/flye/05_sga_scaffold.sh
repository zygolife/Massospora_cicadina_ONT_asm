#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 64 -C ryzen --mem 128gb --out logs/flye_sga_scaffold.%A.log

module load bwa/0.7.17
module load samtools/1.14

CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi

DRAFT=$(realpath asm/scaffold_ragtag/flye_5FC_M_RC8_to_wtdbg2Polish/ragtag.scaffold.fasta)
IN1=$(realpath input/Massospora_2019-06_R1.fq.gz)
IN2=$(realpath input/Massospora_2019-06_R2.fq.gz)
IN1=$(realpath input/Masso_TEST_R1.fa)
IN2=$(realpath input/Masso_TEST_R2.fa)
TARGETDIR=asm/scaffold_sga/flye_ragtag_illumina
GENOMEFILE=genome.fa
BAM=Masso_sgascaf.pe.bam
BAMSORT=Masso_sgascaf.pe.sort.bam
LIBPREF=lib.fragment.300bp
MINLENCTG=200
FINALPREF=Masso_sga.scaf
mkdir -p $TARGETDIR
pushd $TARGETDIR
if [ ! -f $GENOMEFILE ]; then
	ln -s $DRAFT genome.fa
fi
if [ ! -f $GENOME.pac ]; then
	bwa index genome.fa
fi
if [ ! -f $BAM ]; then
	bwa mem -t $CPU $GENOME $IN1 $IN2 | samtools view -O bam --threads 8 -o $BAM
	samtools sort --threads $CPU -o $BAMSORT -O bam $BAM
fi

module load sga/0.10.15
if [ ! -f $LIBPREF.de ]
	sga-bam2de.pl --prefix $LIBPREF -n 4 -m $MINLENCTG $BAM
fi

if [ ! -s contigs.astat ]; then
	sga-astat.py -m $MINLENCTG $BAMSORT > contigs.astat
fi

if [ ! -f $FINALPREF ]; then
	sga scaffold -m $MINLENCTG -a contigs.astat --pe $LIBPREF.de -o $FINALPREF $GENOMEFILE
fi

if [ ! -f $FINALPREF.scaffolds.fa ]; then
	sga scaffold2fasta --write-unplaced -m $MINLENCTG  -o $FINALPREF.scaffolds.fa --use-overlap -a final-graph.asqg.gz $FINALPREF
fi
