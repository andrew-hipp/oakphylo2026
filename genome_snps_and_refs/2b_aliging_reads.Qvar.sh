#!/bin/bash
#SBATCH -J oakphylo2025_var_bwamem
#SBATCH -p general
#SBATCH -A r00626
#SBATCH -o filename_%j.txt
#SBATCH -e filename_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=drewlars@iu.edu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=80
#SBATCH --time=4-0:00:00
#SBATCH --mem=200G



ml gnu-parallel
ml bwa
ml samtools

bwa mem -M -t 80 /N/project/oakphylo2025/Qvar_reference_genome/Qvar_reference.fna /N/project/oakphylo2025/Trimmed_reads/SRR28383171_1.trim.fastq.gz  /N/project/oakphylo2025/Trimmed_reads/SRR28383171_2.trim.fastq.gz  > /N/project/oakphylo2025/Bams/SRR28383171.Qvar.sam

parallel -j 10 < /N/project/oakphylo2025/2b_aliging_reads.Qvar.txt

