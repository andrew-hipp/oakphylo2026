#!/bin/bash
#SBATCH -J oakphylo2025_var_sort
#SBATCH -p general
#SBATCH -A r00626
#SBATCH -o filename_%j.txt
#SBATCH -e filename_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=drewlars@iu.edu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=32
#SBATCH --time=4-00:00:00
#SBATCH --mem=380G



ml gnu-parallel
ml bwa
ml samtools


parallel -j 2 < /N/project/oakphylo2025/3b_sort_sams.txt

