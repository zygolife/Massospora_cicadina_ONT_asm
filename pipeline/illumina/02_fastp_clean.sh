#!/usr/bin/bash -l
#SBATCH -p short -C ryzen -N 1 -n 32 --mem 256gb --out logs/illumina_fastp_clean.%A.log

module load fastp
module load workspace/scratch
module load BBMap
module load pigz
CPU=${SLURM_CPUS_ON_NODE}

if [ ! $CPU ]; then
     CPU=2
fi
bbmapdir=$(dirname $(which bbmap.sh))
adapters=${bbmapdir}/resources/adapters.fa
artifacts=${bbmapdir}/resources/sequencing_artifacts.fa.gz
phiX_adapters=${bbmapdir}/resources/phix174_ill.ref.fa.gz
pref=Massospora_201906
FqFiles=(Massospora_S70.fastq.gz Massospora_S87.fastq.gz)
indir=$(realpath input)
trimF=Massospora_201906.trim_R1.fq.gz
trimR=Massospora_201906.trim_R2.fq.gz
pushd $SCRATCH
if [ ! -f $trimF ]; then
    for t in ${FqFiles[@]};
    do
      rsync -av $indir/$t ./
      base=$(basename $t .fastq.gz)
      bbduk.sh in=$t out=$base.trim.fq ktrim=r k=23 mink=7 hdist=1 tpe tbo ref=${adapters} ftm=5 qtrim=r trimq=15 nullifybrokenquality fixjunk
      bbduk.sh in=$base.trim.fq out=$base.filter_R1.fq out2=$base.filter_R2.fq k=23 hdist=1 ref=${artifacts},${phiX_adapters}
      fastp --thread $CPU --adapter_sequence=AGATCGGAAGAGCACACGTCTGAACTCCAGTCA --adapter_sequence_r2=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT --in1 $base.filter_R1.fq --in2 $base.filter_R2.fq --out1 $base.fastp_trim_R1.fq --out2 $base.fastp_trim_R2.fq 
      mv fastp.json $indir/$base.fastp.json
      mv fastp.html $indir/$base.fastp.html
    done
    cat *.fastp_trim_R1.fq | pigz -c > $indir/$trimF
    cat *.fastp_trim_R2.fq | pigz -c > $indir/$trimR
fi
popd
