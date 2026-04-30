#!/bin/bash
#SBATCH -J oakphylo2025_alba_markduplicates
#SBATCH -p general
#SBATCH -A r00626
#SBATCH -o filename_%j.txt
#SBATCH -e filename_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=drewlars@iu.edu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=20
#SBATCH --time=4-00:00:00
#SBATCH --mem=400G



ml gnu-parallel
ml bwa
ml samtools
ml picard

parallel -j 10 < /N/project/oakphylo2025/4a_markduplicates.Qalba.txt

