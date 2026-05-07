# 9a_fbranch_speciesLevel/

Species-level [Dsuite](https://github.com/millanek/Dsuite) *f*-branch analysis run on the merged VCFs from step 8 of the parent pipeline. Inputs each species as its own taxon; results feed [`../../fbranch_interp/`](../../fbranch_interp/) for downstream summarization.

Run on the Indiana University HPC under `/N/project/oakphylo2025/FBRANCH/`. Dsuite is built locally at `Dsuite/Build/Dsuite` (not committed).

---

## Files

| File | Role |
|------|------|
| [`fBranch_Qalba_allsamples_QalbaReseqTree.sh`](fBranch_Qalba_allsamples_QalbaReseqTree.sh) | SLURM submitter. Runs `DtriosParallel` then `Dsuite Fbranch` on the Qalba merged VCF using the Qalba RAxML tree as the species-tree input. |
| [`fBranch_Qvar_allsamples_QvarReseqTree.sh`](fBranch_Qvar_allsamples_QvarReseqTree.sh) | Same as above for the Qvar reference. |
| [`Fixlabels_alba.sh`](Fixlabels_alba.sh) | Strips `/N/project/oakphylo2025/Bams/` and `.Qalba.sorted.markdups.bam` from sample IDs in the merged VCF (decompresses + edits + writes plain `.vcf`). |
| [`Fixlabels_var.sh`](Fixlabels_var.sh) | Same for the Qvar VCF. |
| [`rename_tree.py`](rename_tree.py) | Replaces tip labels in a Newick tree using a two-column lookup (`tab`-separated: old → new). Usage: `python rename_tree.py <lookup.tsv> <in.tree> <out.tree>`. |
| [`All_samples.txt`](All_samples.txt) | Two-column SRR-accession → species map consumed by `DtriosParallel` (the `SETS` file). |
| [`names_RAxML_bestTree.Qalba_snps_min76.rr`](names_RAxML_bestTree.Qalba_snps_min76.rr) | Species-tree (Newick) with renamed tips, used as the `-t` argument to `DtriosParallel` and as the topology argument to `Dsuite Fbranch`. Qvar equivalent: `names_RAxML_bestTree.Qvar_snps_min76.rr`. |
| `plotfBranch.oakphylo2025.{Qalba,Qvar}.{png,svg}` | Plots of the *f*-branch matrix produced by Dsuite's plotting utility. |

---

## Pipeline

```
8_merge_calls.sh output (multi-sample VCF)
       │
       ▼
Fixlabels_{alba,var}.sh        # clean BAM-path prefixes from sample IDs
       │
       ▼
DtriosParallel  +  All_samples.txt  +  species tree (.rr)
       │
       ▼
DTparallel_*_combined_{tree,BBAA,Dmin}.txt
       │
       ▼
Dsuite Fbranch  →  Results_fBranch.oakphylo2025.{Qalba,Qvar}.merged_calls.2026_02_06
       │
       ▼
copied to ../../fbranch_interp/data/
```

---
*This README was written by Claude Code (claude.ai/code) with Andrew Hipp's permission — 2026-05-06.*
