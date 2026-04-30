#!/bin/bash
#SBATCH -J fix_alba_names
#SBATCH -p general
#SBATCH -A r00626
#SBATCH -o filename_%j.txt
#SBATCH -e filename_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=drewlars@iu.edu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time=18:00:00
#SBATCH --mem=20G

cd /N/project/oakphylo2025/FBRANCH/

ml python

zcat /N/project/oakphylo2025/WGS_datasets/oakphylo2025.Qalba.merged_calls_2025_06_27.vcf.gz | sed 's/\/N\/project\/oakphylo2025\/Bams\///g' | sed 's/\.Qalba\.sorted\.markdups\.bam//g' > oakphylo2025.Qalba.merged_calls_2025_06_27.vcf




