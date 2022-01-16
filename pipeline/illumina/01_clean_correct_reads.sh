#!/usr/bin/bash -l
#SBATCH -p short -C ryzen -N 1 -n 96 --mem 256gb --out logs/illumina_clean.%A.log

module load BBMap
module load workspace/scratch

# Use bbduk.sh to quality and length trim the Illumina reads and remove adapter sequences
# 1. ftm = 5, right trim read length to a multiple of 5
# 2. k = 11, Kmer length used for finding contaminants
# 3. ktrim=r, Trim reads to remove bases matching reference kmers to the right
# 4. mink=7, look for shorter kmers at read tips down to 7 bps
# 5. qhdist=1, hamming distance for query kmers
# 6. tbo, trim adapters based on where paired reads overlap
# 7. tpe, when kmer right-trimming, trim both reads to the minimum length of either
# 8. qtrim=r, trim read right ends to remove bases with low quality
# 9. trimq=15, regions with average quality below 10 will be trimmed.
# 10. minlength=70, reads shorter than 70bps after trimming will be discarded.
# 11. ref=$adapters, adapters shipped with bbnorm tools
# 12. –Xmx8g, use 8G memory
# 13. 1>trim.o 2>&1, redirect stderr to stdout, and save both to file *trim.o*
bbmapdir=$(dirname $(which bbmap.sh))
adapters=${bbmapdir}/resources/adapters.fa
artifacts=${bbmapdir}/resources/sequencing_artifacts.fa.gz
phiX_adapters=${bbmapdir}/resources/phix174_ill.ref.fa.gz
pref=Massospora_201906
FqFiles=(Massospora_S70.fastq.gz Massospora_S87.fastq.gz)
indir=$(realpath input)

pushd $SCRATCH;
filter=$pref.filter.fq

merged=$indir/${pref}.ecc.fq.gz
unmerged=$indir/${pref}.unmerged_ecc.fq.gz
#leftTecc=$(basename $left .fq.gz).tecc.fq.gz
#rightTecc=$(basename $right .fq.gz).tecc.fq.gz


if [ ! -f $filter ]; then
    for t in ${FqFiles[@]};
    do
      rsync -av $indir/$t ./
      bbduk.sh in=$t out=$(basename $t .fastq.gz).trim.fq ktrim=r k=23 mink=7 hdist=1 tpe tbo ref=${adapters} ftm=5 qtrim=r trimq=15 nullifybrokenquality fixjunk
      bbduk.sh in=$(basename $t .fastq.gz).trim.fq out=$(basename $t .fastq.gz).filter.fq k=23 hdist=1 ref=${artifacts},${phiX_adapters}
    done
    cat *.filter.fq > $filter
fi

if [ ! -f $merged ]; then
    bbmerge-auto.sh in=$filter out=$merged outu=$unmerged ihist=ihist.txt extend2=20 iterations=10 k=31 ecct
#    bbmerge.sh in=$leftfilter in2=$rightfilter out=$merged outu1=$unmergedL $outu2=$unmergedR ecco mix adapters=default
  reformat.sh in=$merged out=$(echo -n $merged | perl -p -e 's/\.fq\.gz/.fa.gz/')
  reformat.sh in=$unmerged out=$(echo -n $unmerged | perl -p -e 's/\.fq\.gz/.fa.gz/')
fi
