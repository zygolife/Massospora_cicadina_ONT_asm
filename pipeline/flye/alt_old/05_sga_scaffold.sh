#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 128 -C ryzen --mem 128gb --out logs/flye_sga_scaffold.%A.log

module load bwa-mem2
module load samtools/1.14

CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi

DRAFT=$(realpath asm/scaffold_ragtag/flye_5FC_M_RC8_to_wtdbg2Polish/ragtag.scaffold.fasta)
IN1=$(realpath input/Massospora_201906.trim_R1.fq.gz)
IN2=$(realpath input/Massospora_201906.trim_R2.fq.gz)
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
if [ ! -f $GENOMEFILE.pac ]; then
	bwa-mem2 index genome.fa
fi
if [ ! -f $BAM ]; then
	bwa-mem2 mem -t $CPU $GENOMEFILE $IN1 $IN2 | samtools view -O bam --threads 8 -F 2304 -o $BAM
	samtools sort --threads $CPU -o $BAMSORT -O bam $BAM
	samtools index $BAMSORT
fi

module load sga/0.10.15
module load bamtools
if [ ! -f $LIBPREF.de ]; then
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
