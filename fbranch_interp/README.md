# fbranch_interp/

R script for parsing and summarizing *f*-branch (Dsuite) gene-flow / admixture results from the whole-genome resequencing pipeline. Produces the per-section *f*-branch table reported in the manuscript and `FIG5_*` plot files.

Script by Andrew Hipp (ahipp@mortonarb.org).

---

## Inputs

All inputs are committed under [`data/`](data/) and originate from the Dsuite runs in [`../genome_snps_and_refs/9a_fbranch_speciesLevel/`](../genome_snps_and_refs/9a_fbranch_speciesLevel/):

| File | Source | Role |
|------|--------|------|
| `Results_fBranch.oakphylo2025.Qalba.merged_calls.2026_02_06` | `Dsuite Fbranch` (Qalba reference) | Per-branch *f*-branch matrix |
| `Results_fBranch.oakphylo2025.Qvar.merged_calls.2026_02_06` | `Dsuite Fbranch` (Qvar reference) | Per-branch *f*-branch matrix |
| `DTparallel_All_samples_Dtrios.*_combined_BBAA.txt` | `DtriosParallel` | BBAA-resolved Dtrios output |
| `DTparallel_All_samples_Dtrios.*_combined_Dmin.txt` | `DtriosParallel` | Dmin-resolved Dtrios output |
| `DTparallel_All_samples_Dtrios.*_combined_tree.txt` | `DtriosParallel` | Tree-resolved Dtrios output |
| `reseqTaxa.csv` | hand-curated | Maps each `Quercus_<species>` to its taxonomic section |

Only the two `Results_fBranch.*` files and `reseqTaxa.csv` are read by the current `fb.R`; the Dtrios files are kept here for reference and reproducibility.

---

## Running

From an R session with working directory set to `fbranch_interp/`:

```r
source("scripts/fb.R")
```

R packages required: `readr`, `tidyr`, `tidyverse` (which pulls in `dplyr`, `ggplot2`, etc.).

---

## What the Script Does

1. Reads the two *f*-branch result tables (Qalba, Qvar) and the species → section lookup.
2. Tags each *f*-branch row by its **row section** (`rowSect`) and **column section** (`colSect`):
   - For terminal branches (a single species), the row's section is the species' section.
   - For internal branches, if all descendants share a section → that section; otherwise `MIXED`.
3. Classifies each cell as `compareSect = rowSect` (within-section gene flow) or `INTERSECTION` (between-section gene flow).
4. Computes mean ± SEM and *n* per `compareSect` group, dropping `MIXED` rows.
5. Writes summary tables and identifies the top 30 *f*-branch values (with descendant lists for internal branches).

---

## Outputs

[`out/`](out/):

| File | Contents |
|------|----------|
| `fbranchMean_by_sect.csv` | Mean / SD / SEM / *n* of *f*-branch values, per `compareSect` (within-section vs `INTERSECTION`) |
| `TABLE2_fbranchMean_by_sect.csv` | Manuscript Table 2 — `compareSect`, formatted `mean +/- SEM`, *n* |
| `fb_max_alba.csv` | Top 30 *f*-branch values for the Q. alba reference, with the partner clade for each |

[`out_dsuite/`](out_dsuite/):

| File | Contents |
|------|----------|
| `FIG5_plotfBranch.oakphylo2025.Qalba.svg` | Manuscript Figure 5 (Q. alba reference) |
| `plotfBranch.oakphylo2025.Qalba.{png,svg}`, `plotfBranch.oakphylo2025.Qvar.{png,svg}` | Dsuite-generated *f*-branch plots, copied from `../genome_snps_and_refs/9a_fbranch_speciesLevel/` for convenience |

---

## Layout

```
fbranch_interp/
├── scripts/fb.R          # main analysis script
├── data/                 # Dsuite outputs + reseqTaxa.csv (inputs)
├── out/                  # CSV summary outputs
└── out_dsuite/           # SVG/PNG figures (incl. FIG5)
```

---

## Reference

Malinsky M, Matschiner M, Svardal H. 2021. Dsuite — fast *D*-statistics and related admixture evidence from VCF files. *Molecular Ecology Resources* 21: 584–595.

---
*This README was written by Claude Code (claude.ai/code) with Andrew Hipp's permission — 2026-05-06.*
