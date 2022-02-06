#!/usr/bin/bash -l
#SBATCH -p short -N 1 -n 32 -p intel,batch --out quast.%A.log --mem 128gb

module load QUAST/5.1.0rc1
CPU=2
if [ ! -z $SLURM_CPUS_ON_NODE ]; then
	CPU=$SLURM_CPUS_ON_NODE
fi
quast.py --pe1 Massospora_2019-06_R1.fq.gz --pe2 Massospora_2019-06_R2.fq.gz  --fungus --large --threads $CPU -o flye_vs_wtdbg -l $(cat labels.txt) $(perl -p -e 's/\n/ /g' asms.txt)
