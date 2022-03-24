#!/usr/bin/bash -l
#SBATCH -p batch,intel -N 1 -n 32 --mem 256gb --out logs/flye_M_R8_ragTag_tadpole.%A.log
module load BBMap
module load workspace/scratch
MEM=256g
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi
DRAFT=$(realpath asm/scaffold_ragtag/flye_5FC_M_RC8_to_wtdbg2Polish/ragtag.scaffold.fasta)
INFASTQUNPAIRED=$(realpath input/Massospora_201906.ecc.fq.gz)
INFASTQUNMERGED=$(realpath input/Massospora_201906.unmerged_ecc.fq.gz)
INFASTQUNMERGEDF=$(realpath input/Massospora_201906.unmerged_ecc.R1.fa.gz)
INFASTQUNMERGEDR=$(realpath input/Massospora_201906.unmerged_ecc.R2.fa.gz)
OUTDIR=asm/tadpole_extend/flye_5FC_medaka_R8_scafRagtag
mkdir -p $OUTDIR
OUTDIR=$(realpath $OUTDIR)

LAST=
for ROUND in $(seq 5)
do
  CONS=$OUTDIR/Masso.tadpole_round${ROUND}.fasta
  echo "Running Round $ROUND to produced $CONS"
  if [ ! -s $CONS.gz ]; then
    tadpole.sh in=$DRAFT out=$CONS el=100 er=100 mode=extend extra=$INFASTQUNPAIRED,$INFASTQUNMERGED k=80 prealloc=t
    STATS=$(echo -n $CONS | perl -p -e 's/\.fasta/.stats.txt/')
    module load AAFTF
    AAFTF assess -i $CONS -r $STATS
    pigz $CONS
  fi
  DRAFT=$CONS.gz
done
