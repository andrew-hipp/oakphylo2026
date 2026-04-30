#!/bin/bash
#SBATCH -J oakphylo2025_zip
#SBATCH -p general
#SBATCH -A r00626
#SBATCH -o filename_%j.txt
#SBATCH -e filename_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=drewlars@iu.edu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH --time=1-00:00:00
#SBATCH --mem=120G


ml gnu-parallel

cd /N/project/oakphylo2025/Project_raw_reads

ls *.fastq | parallel -j 12 gzip
