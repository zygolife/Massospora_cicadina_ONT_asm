#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 64 -C xeon --mem 128gb --out logs/ragtag_scaf_wtDB.%A.log

module load ragtag
module load minimap2/2.24

CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi
QUERY=$(realpath asm/racon/flye_5FC_medaka/racon.round8.fasta)
TARGET=$(realpath asm/wtdbg2_5FC/Masso_5FC.polish1.fa)
OUTDIR=asm/scaffold_ragtag/flye_5FC_M_RC8_to_wtdbg2Polish
mkdir -p $OUTDIR
ragtag.py scaffold -g 50 -u -r -t $CPU $TARGET $QUERY
