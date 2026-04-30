#!/bin/bash
#SBATCH -J oakphylo2025_alba_filter_index
#SBATCH -p general
#SBATCH -A r00626
#SBATCH -o filename_%j.txt
#SBATCH -e filename_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=drewlars@iu.edu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=40
#SBATCH --time=4-00:00:00
#SBATCH --mem=200G



ml gnu-parallel
ml bwa
ml samtools
ml picard
ml bcftools

parallel -j 40 < /N/project/oakphylo2025/6a_filter_index_Qalba.txt

