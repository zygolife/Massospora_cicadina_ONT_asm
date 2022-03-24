#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 64 -C xeon --mem 128gb --out logs/ragtag_patch_RC_wtDB.%A.log

module load ragtag
module load minimap2

CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi
DRAFT=$(realpath asm/racon/flye_5FC_medaka/racon.round8.fasta)
INFASTQUNPAIRED=$(realpath input/Massospora_201906.ecc.fasta.gz)
INFASTQUNMERGED=$(realpath input/Massospora_201906.unmerged_ecc.fasta.gz)
OUTDIR=asm/scaffold_shortread/flye_5C_M_RC8
mkdir -p $OUTDIR
ragtag.py patch -t $CPU -s 1000 -f 200 --aligner minimap2 -u -o $OUTDIR $DRAFT $INFASTQUNPAIRED
