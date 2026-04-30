#!/bin/bash
#SBATCH -J Dtrios.oakphylo2025.Qalba.merged_calls.2026_02_06
#SBATCH -p general
#SBATCH -A r00626
#SBATCH -o filename_%j.txt
#SBATCH -e filename_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=drewlars@iu.edu
#SBATCH --nodes=1
#SBATCH --cpus-per-task=60
#SBATCH --time=4-00:00:00
#SBATCH --mem=100G

cd /N/project/oakphylo2025/FBRANCH/

ml python

./Dsuite/utils/DtriosParallel All_samples.txt oakphylo2025.Qalba.merged_calls_2025_06_27.vcf -t names_RAxML_bestTree.Qalba_snps_min76.rr --cores 60 -n Dtrios.oakphylo2025.Qalba.merged_calls.2026_02_06

./Dsuite/Build/Dsuite Fbranch names_RAxML_bestTree.Qalba_snps_min76.rr DTparallel_All_samples_Dtrios.oakphylo2025.Qalba.merged_calls.2026_02_06_combined_tree.txt > Results_fBranch.oakphylo2025.Qalba.merged_calls.2026_02_06





