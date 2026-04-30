#!/bin/bash
#SBATCH -J oakphylo2025_depth
#SBATCH -p general
#SBATCH -A r00626
#SBATCH -o filename_%j.txt
#SBATCH -e filename_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=drewlars@iu.edu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=40
#SBATCH --time=1-00:00:00
#SBATCH --mem=100G



ml gnu-parallel
ml bwa
ml samtools
ml picard

parallel -j 40 < /N/project/oakphylo2025/4d_samtools_depth.txt

