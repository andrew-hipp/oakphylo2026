#!/bin/bash
#SBATCH -J oakphylo2025_download_SRA_reads
#SBATCH -p general
#SBATCH -A r00626
#SBATCH -o filename_%j.txt
#SBATCH -e filename_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=drewlars@iu.edu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=24
#SBATCH --time=2-00:00:00
#SBATCH --mem=120G



ml sra-toolkit
ml gnu-parallel

parallel -j 12 < /N/project/oakphylo2025/download_SRA_oakphylo2025.txt
