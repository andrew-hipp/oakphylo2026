# oakphylo2026

Code and analyses for an oak phylogenetics book chapter (2026) comparing phylogenetic trees across three genomic datasets for *Quercus* (oak) species. The study builds on the global oak phylogeny (Hipp et al. 2020, *New Phytologist* 226: 1198–1212).

## Repository Structure

| Folder | Description |
|--------|-------------|
| [`topologies/`](topologies/) | Core analysis: compare tree topologies across RAD-seq and whole-genome resequencing datasets using MDS ordination, cophyloplots, rogue taxa analysis, and clade-support summaries. Primary R pipeline. |
| [`genome_snps_and_refs/`](genome_snps_and_refs/) | Shell and Python scripts for SNP calling and pseudoreference genome generation from whole-genome resequencing data. Numbered pipeline (steps 0–9), plus *f*-branch admixture analyses. Scripts by Drew Larson. |
| [`RADinitio/`](RADinitio/) | RAD-seq simulation pipeline using RADinitio. Takes a reference genome and produces simulated RAD loci for downstream tree inference. Scripts by K. Althaus. |
| [`fbranch_interp/`](fbranch_interp/) | R script for interpreting *f*-branch (Dsuite) gene flow / admixture results. |

## Datasets

Three genomic datasets are compared across analyses:

- **empiricalRAD** — empirical RAD-seq data assembled against reference genomes (RAxML trees)
- **simRAD** — RAD-seq data simulated with RADinitio from whole-genome sequences (RAxML trees)
- **reSeq** — pseudoreference whole-genome resequencing (RAxML trees)

## Quick Start (topologies pipeline)

From an R session with the working directory set to `topologies/`:

```r
source("scripts/000_doItAll.R")   # full pipeline
```

Key flags at the top of `000_doItAll.R`:
- `globalDoPDF = FALSE` — set `TRUE` to regenerate all PDF outputs
- `rogues = FALSE` — set `TRUE` to rerun rogue taxa analysis (slow)

See [`topologies/CLAUDE.md`](topologies/CLAUDE.md) for full pipeline documentation, script order, data layout, and conventions.

## Reference

Hipp AL, Manos PS, Hahn M, Avishai M, Bodénès C, Cavender-Bares J, Crowl AA, Deng M, Denk T, Fitz-Gibbon S, et al. 2020. Genomic landscape of the global oak phylogeny. *New Phytologist* 226: 1198–1212.

---
*This README was updated by Claude Code (claude.ai/code) with Andrew Hipp's permission — 2026-05-03.*
