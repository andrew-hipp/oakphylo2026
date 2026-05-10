# oakphylo2026

[![DOI](https://zenodo.org/badge/1131918970.svg)](https://doi.org/10.5281/zenodo.20084868)

Code and analyses for an oak phylogenetics book chapter (2026) comparing phylogenetic trees across three genomic datasets for *Quercus* (oak) species using a previosly-published RADseq dataset (from Hipp et al. 2020, *New Phytologist* 226: 1198–1212; Althaus et al. 2026, *PNAS* 139: e2537040123), a new whole genome resequencing dataset, and a simulated RADseq dataset based on the latter.

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

---
*This README was updated by Claude Code (claude.ai/code) with Andrew Hipp's permission — 2026-05-03.*
