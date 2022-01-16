#!/usr/bin/bash
#SBATCH -p short -N 1 -n 2 --mem 2gb --out logs/canu_launch.log

module load canu

canu -nanopore-raw input/guppy6/5FC.guppy6_0_1.fastq.gz useGrid=true -d asm/canu_5FC -p Masso_5FC genomeSize=1.1g gridOptions="-p batch,intel"
