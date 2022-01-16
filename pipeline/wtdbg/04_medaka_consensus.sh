#!/usr/bin/bash
#SBATCH -p gpu -n 1 -n 2 --mem 64gb --out logs/medaka_consensus.%A.log  --gres=gpu:1 --time 12:00:00 --array 1-28
module unload miniconda2
module unload miniconda3
module load medaka/1.4.3-gpu
module load workspace/scratch

CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi
N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
    N=$1
    if [ ! $N ]; then
        echo "need to provide a number by --array or cmdline"
        exit
    fi
fi

READS=input/guppy6/5FC.guppy6_0_1.fastq.gz
DRAFT=asm/racon/wtdbg_round1/racon.fasta
INDIR=$(dirname $DRAFT)
OUTDIR=asm/medaka/wtdbg_round1
TMPSPLIT=$OUTDIR/split_cons
mkdir -p $TMPSPLIT
CHUNK=1000
MAX=$(grep -c "^>" $DRAFT)
NSTART=$(perl -e "printf('%d',1 + $CHUNK * ($N - 1))")
NEND=$(perl -e "printf('%d',$CHUNK * $N)")
if [ "$NSTART" -gt "$MAX" ]; then
	echo "NSTART ($NSTART) > $MAX"
	exit
fi
if [ "$NEND" -gt "$MAX" ]; then
	NEND=$MAX
fi
echo "$NSTART -> $NEND"
if [[ ! -f names.txt || $DRAFT -nt names.txt ]]; then
	grep "^>" $DRAFT | perl -p -e 's/>(\S+)\s+.+/$1/' > $INDIR/names.txt
fi

CTGS=$(sed -n "${NSTART},${NEND}p" $INDIR/names.txt | perl -p -e 's/\n/ /g')

if [ ! -f $TMPSPLIT/chunk_${N}.hdf ]; then
	time medaka consensus $OUTDIR/calls_to_draft.bam $TMPSPLIT/chunk_${N}.hdf --model r941_min_high_g344 --batch_size 100 --threads $CPU \
	--region $CTGS
fi
