#!/bin/bash
#SBATCH -J oakphylo2025_var_mpileup_call2
#SBATCH -p general
#SBATCH -A r00626
#SBATCH -o filename_%j.txt
#SBATCH -e filename_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=drewlars@iu.edu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=80
#SBATCH --time=4-00:00:00
#SBATCH --mem=400G



ml gnu-parallel
ml bwa
ml samtools
ml picard
ml bcftools

parallel -j 5 < /N/project/oakphylo2025/5b_mpileup_call_Qvar.txt
