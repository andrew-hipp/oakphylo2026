#!/bin/bash
#SBATCH -J oakphylo2025_alba_bwamem_unpaired
#SBATCH -p general
#SBATCH -A r00626
#SBATCH -o filename_%j.txt
#SBATCH -e filename_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=drewlars@iu.edu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=24
#SBATCH --time=1-00:00:00
#SBATCH --mem=60G



ml gnu-parallel
ml bwa
ml samtools


parallel -j 3 < /N/project/oakphylo2025/2a_aliging_reads.unpaired.Qalba.txt

