#!/bin/bash
#SBATCH -J oakphylo2025_alba_bwamem
#SBATCH -p general
#SBATCH -A r00626
#SBATCH -o filename_%j.txt
#SBATCH -e filename_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=drewlars@iu.edu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=80
#SBATCH --time=3-00:00:00
#SBATCH --mem=200G



ml gnu-parallel
ml bwa
ml samtools


parallel -j 10 < /N/project/oakphylo2025/2a_aliging_reads.Qalba.txt

