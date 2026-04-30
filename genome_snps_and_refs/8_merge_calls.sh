#!/bin/bash
#SBATCH -J oakphylo2025_merge
#SBATCH -p general
#SBATCH -A r00626
#SBATCH -o filename_%j.txt
#SBATCH -e filename_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=drewlars@iu.edu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=24
#SBATCH --time=1-00:00:00
#SBATCH --mem=200G



ml gnu-parallel
ml bwa
ml samtools
ml picard
ml bcftools

parallel -j 2 < /N/project/oakphylo2025/8_merge_calls.txt 

