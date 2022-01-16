#!/usr/bin/bash
#SBATCH -p gpu -n 1 -n 24 --mem 300gb --out logs/medaka.%A.log  --gres=gpu:1 --time 64:00:00
module unload miniconda2
module unload miniconda3
module load medaka/1.4.3-gpu
CPU=$SLURM_CPUS_ON_NODE
if [ -z $CPU ]; then
	CPU=1
fi

BASECALLS=input/Masso_6FC.Nanopore.fastq.gz
DRAFT=asm/racon/round1/racon.fasta
OUTDIR=asm/medaka/consensus_racon1
mkdir -p $OUTDIR
# guppy was run 
# module load guppy/3.4.4-gpu
# guppy_basecaller -c dna_r9.4.1_450bps_hac.cfg -r -x "auto" \
#    -s $OUT -i $IN --compress_fastq --num_callers 16 --fast5_out $OUT5 \
#    --gpu_runners_per_device 24 --chunks_per_runner 900 --qscore_filtering --min_qscore 7
#--device "cuda:$CUDA_VISIBLE_DEVICES" \
medaka_consensus -i ${BASECALLS} -d ${DRAFT} -o ${OUTDIR} -t $CPU  -m r941_min_high_g344 -b 100


