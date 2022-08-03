#!/usr/bin/bash
#SBATCH -p gpu -n 1 -n 8 --mem 50gb --out logs/medaka_consensus.%a.log  --gres=gpu:1 --time 8:00:00 --array 1-28
module unload miniconda2
module unload miniconda3
module load medaka/1.4.3-gpu
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


BASECALLS=input/Masso_6FC.Nanopore.fastq.gz
DRAFT=asm/racon/round1/racon.fasta
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
	grep "^>" $DRAFT | perl -p -e 's/>(\S+)\s+.+/$1/' > names.txt
fi

CTGS=$(sed -n "${NSTART},${NEND}p" names.txt | perl -p -e 's/\n/ /g')
OUTDIR=asm/medaka/consensus_racon1
TMPSPLIT=$OUTDIR/split_cons
mkdir -p $TMPSPLIT
# guppy was run 
# module load guppy/3.4.4-gpu
# guppy_basecaller -c dna_r9.4.1_450bps_hac.cfg -r -x "auto" \
#    -s $OUT -i $IN --compress_fastq --num_callers 16 --fast5_out $OUT5 \
#    --gpu_runners_per_device 24 --chunks_per_runner 900 --qscore_filtering --min_qscore 7
#--device "cuda:$CUDA_VISIBLE_DEVICES" \

if [ ! -f $TMPSPLIT/chunk_${N}.hdf ]; then
	time medaka consensus $OUTDIR/calls_to_draft.bam $TMPSPLIT/chunk_${N}.hdf --model r941_min_high_g344 --batch_size 100 --threads $CPU \
	--region $CTGS
fi

