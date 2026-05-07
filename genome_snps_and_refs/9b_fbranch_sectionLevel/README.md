# 9b_fbranch_sectionLevel/

Section-level [Dsuite](https://github.com/millanek/Dsuite) *f*-branch analysis. Same workflow as [`../9a_fbranch_speciesLevel/`](../9a_fbranch_speciesLevel/) but samples are grouped by *Quercus* taxonomic section rather than treated as individual species, so admixture is summarized between sections instead of between species.

Run on the Indiana University HPC under `/N/project/oakphylo2025/FBRANCH_sections/`. Reuses the Dsuite build from `../FBRANCH/Dsuite/`.

---

## Files

| File | Role |
|------|------|
| [`sections_fBranch_Qalba_allsamples_QalbaReseqTree.sh`](sections_fBranch_Qalba_allsamples_QalbaReseqTree.sh) | SLURM submitter. Runs `DtriosParallel` + `Dsuite Fbranch` using the section-grouped sample map and the section-collapsed species tree. |
| [`All_samples_sections.txt`](All_samples_sections.txt) | Two-column SRR-accession → section map (the `SETS` file for `DtriosParallel`). |
| [`sections_names_RAxML_bestTree.Qalba_snps_min76.rr`](sections_names_RAxML_bestTree.Qalba_snps_min76.rr) | Section-level species tree (tips are sections), used as `-t` to `DtriosParallel` and topology argument to `Dsuite Fbranch`. |
| [`sectionLevel_results/`](sectionLevel_results/) | Outputs: `Results_sections_fBranch.oakphylo2025.Qalba.merged_calls.2026_03_23` plus the three `DTparallel_*_combined_{tree,BBAA,Dmin}.txt` files. |
| `sections_plotfBranch.oakphylo2025.Qalba.{png,svg}` | Plots of the section-level *f*-branch matrix. |

Only Qalba is run at section level (no Qvar equivalent).

---

## Difference from 9a

The species-level run (`9a_*`) places one tip per species in the topology. The section-level run (`9b_*`) collapses species into sections before `Dtrios`, so each *f*-branch cell summarizes one section's admixture with another. Both runs share the underlying merged VCF from step 8 of the parent pipeline.

---
*This README was written by Claude Code (claude.ai/code) with Andrew Hipp's permission — 2026-05-06.*
