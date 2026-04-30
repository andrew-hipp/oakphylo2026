#!/bin/bash
#SBATCH -J oakphylo2025_fastp_trimming
#SBATCH -p general
#SBATCH -A r00626
#SBATCH -o filename_%j.txt
#SBATCH -e filename_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=drewlars@iu.edu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=24
#SBATCH --time=2-00:00:00
#SBATCH --mem=240G



#ml sra-toolkit
ml gnu-parallel
ml fastp
ml fastqc 

#parallel -j 12 < /N/project/oakphylo2025/1a_run_fastp_all.txt

cd /N/project/oakphylo2025/Trimmed_reads

ls *.trim.fastq.gz | parallel -j 12 fastqc
