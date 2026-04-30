#!/bin/bash
#SBATCH -J sections_Dtrios.oakphylo2025.Qalba.merged_calls.2026_03_23
#SBATCH -p general
#SBATCH -A r00626
#SBATCH -o filename_%j.txt
#SBATCH -e filename_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=drewlars@iu.edu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=60
#SBATCH --time=2-00:00:00
#SBATCH --mem=100G

cd /N/project/oakphylo2025/FBRANCH_sections

ml python

../FBRANCH/Dsuite/utils/DtriosParallel All_samples_sections.txt ../FBRANCH/oakphylo2025.Qalba.merged_calls_2025_06_27.vcf -t sections_names_RAxML_bestTree.Qalba_snps_min76.rr --cores 60 -n Dtrios.sections.oakphylo2025.Qalba.merged_calls.2026_03_23


../FBRANCH/Dsuite/Build/Dsuite Fbranch sections_names_RAxML_bestTree.Qalba_snps_min76.rr DTparallel_All_samples_sections_Dtrios.sections.oakphylo2025.Qalba.merged_calls.2026_03_23_combined_tree.txt > Results_sections_fBranch.oakphylo2025.Qalba.merged_calls.2026_03_23

