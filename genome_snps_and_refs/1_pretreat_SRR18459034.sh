#!/bin/bash
#SBATCH -J oakphylo2025_skewer
#SBATCH -p debug
#SBATCH -A r00626
#SBATCH -o filename_%j.txt
#SBATCH -e filename_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=drewlars@iu.edu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=48
#SBATCH --time=0-01:00:00
#SBATCH --mem=120G



/N/project/oakphylo2025/apps/skewer-0.2.2-linux-x86_64 -x /N/project/oakphylo2025/1_adapters_and_overRepresented.fa /N/project/oakphylo2025/Project_raw_reads/SRR18459034_1.fastq.gz /N/project/oakphylo2025/Project_raw_reads/SRR18459034_2.fastq.gz -o /N/project/oakphylo2025/Project_raw_reads/SRR18459034 --threads 48

