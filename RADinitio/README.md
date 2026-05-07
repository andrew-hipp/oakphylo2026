# RADinitio/

Pipeline for simulating RAD-seq data from whole-genome sequences using [RADinitio](https://catchenlab.life.illinois.edu/radinitio/). The simulated reads are subsequently assembled (externally) into RAxML trees that feed the `simRAD` dataset in [`../topologies/`](../topologies/).

Scripts by Kieran Althaus (kalthaus@mortonarb.org / kalthaus@uchicago.edu).

---

## Pipeline Overview

```
whole-genome FASTAs              parse_fastas.sh / split_fastas.{sh,py}
       │                                    │
       │  (preprocessing: concatenate /     │  removeGapMSA.py
       │   split / clean MSAs as needed)    │
       ▼                                    ▼
┌──────────────────────────────────────────────────┐
│ OakBookChapter_radinitioPipeline.sh              │
│                                                  │
│   Step 1: radinitio --make-population            │
│   Step 2: radinitio --make-library-seq           │
└──────────────────────────────────────────────────┘
       │
       ▼
simulated RAD reads (FASTQ)  →  external assembly + RAxML
                            →  topologies/data/simulated_RAD/
```

---

## Scripts

| Script | Role |
|--------|------|
| [`OakBookChapter_radinitioPipeline.sh`](OakBookChapter_radinitioPipeline.sh) | **Primary pipeline.** Iterates over `*Qalba.fasta.gz` reference genomes; runs `radinitio --make-population` then `radinitio --make-library-seq` for each. |
| [`parse_fastas.sh`](parse_fastas.sh) | Concatenate multi-chromosome FASTA files into a single sequence per file and rename the header to match the filename. Used as preprocessing before RADinitio. |
| [`split_fastas.py`](split_fastas.py) | Split a multiple sequence alignment (MSA) into one FASTA file per sequence ID. Python implementation. |
| [`split_fastas.sh`](split_fastas.sh) | Same purpose as `split_fastas.py`, written in bash/awk. Either is fine; pick by environment. |
| [`removeGapMSA.py`](removeGapMSA.py) | Remove all alignment columns containing `-` or `?` in any sequence. Two-pass implementation for large alignments. |

---

## Running the Primary Pipeline

```bash
# Edit paths at the top of OakBookChapter_radinitioPipeline.sh first
bash OakBookChapter_radinitioPipeline.sh
```

**Hard-coded paths** (edit before running):
- `GENOMES_DIR` — directory containing `*.Qalba.fasta.gz` reference genomes
- `POPULATION_OUT_DIR` — output for `--make-population`
- `LIBRARY_OUT_DIR` — output for `--make-library-seq`

**Modeling parameters** (edit at the top of the script):

| Parameter | Value | Stage |
|-----------|-------|-------|
| `min_seq_len` | 1000000 | make-population |
| `n_pops` | 1 | make-population |
| `pop_eff_size` | 1 | make-population |
| `n_seq_indv` | 1 | make-population |
| `enz` | `PstI` | both |
| `pop_mig_rate` | 0 | make-population |
| `library_type` | `sdRAD` | make-library-seq |
| `insert_mean` / `insert_stdev` | 450 / 50 | make-library-seq |
| `pcr_model` / `pcr_cycles` | `inheff` / 12 | make-library-seq |
| `coverage` | 30 | make-library-seq |
| `read_length` | 100 | make-library-seq |
| `read_out_fmt` | `fastq` | make-library-seq |

The script also reads a chromosome list from `data/chrom_list.txt` (relative to wherever the script is run).

The genome-file glob pattern is currently `*.Qalba.fasta.gz` (i.e., processes Q. alba pseudoreferences); change the glob and the `basename ... .Qalba.fasta.gz` calls to run the same pipeline on Q. variabilis or other references.

---

## Software Dependencies

- [`radinitio`](https://catchenlab.life.illinois.edu/radinitio/) on PATH
- bash 4+ (`mapfile`, `[[ ]]`)
- Python 3 (for `*.py` helpers)
- Standard Unix tools: `awk`, `grep`, `sed`, `find`

---

## Outputs

`OakBookChapter_radinitioPipeline.sh` produces, per reference genome:
- `make_population_out/<genome_name>/` — coalescent simulation outputs
- `make_library_out/<genome_name>/` — simulated RAD-seq FASTQ files

Downstream assembly (ipyrad / similar) and RAxML inference happen **outside this folder**; final tree files land in [`../topologies/data/simulated_RAD/`](../topologies/data/simulated_RAD/).

---

## Reference

Rivera-Colón AG, Rochette NC, Catchen JM. 2021. Simulation with RADinitio improves RADseq experimental design and sheds light on sources of missing data. *Molecular Ecology Resources* 21: 363–378.

---
*This README was written by Claude Code (claude.ai/code) with Andrew Hipp's permission — 2026-05-06.*
