# genome_snps_and_refs/

SLURM-based pipeline for SNP calling and pseudoreference generation from whole-genome resequencing reads, plus *f*-branch admixture analyses (Dsuite). Outputs feed both [`../topologies/data/ReSeq_phylos/`](../topologies/data/ReSeq_phylos/) (the `reSeq` dataset) and [`../fbranch_interp/data/`](../fbranch_interp/data/) (gene-flow interpretation).

Scripts by Drew Larson (dlarson@ed.ac.uk).

> **Note on portability.** These scripts target the Indiana University HPC and use absolute paths under `/N/project/oakphylo2025/`, the SLURM `r00626` allocation, and the IU module system (`ml bwa`, `ml samtools`, etc.). They are committed for reproducibility and provenance — running them elsewhere requires editing every path. Each numbered step has a `.sh` SLURM submitter and a paired `.txt` job list; the submitter calls `parallel` over the `.txt` file.

---

## Pipeline Overview

```
0_download_SRA  →  1a_run_fastp_all  →  2{a,b}_aligning_reads  →  3{a,b}_sort_sams
                                                                        │
                                                                        ▼
                              4{a,b}_markduplicates  ←  4c_samtools_depth (QC)
                                        │
                                        ▼
              5{a,b}_mpileup_call  →  6{a,b}_filter_index  →  7{a,b}_consensus
                                                                   │
                                                                   ▼
                                                          8_merge_calls (per-reference VCF)
                                                                   │
                                                  ┌────────────────┴────────────────┐
                                                  ▼                                 ▼
                       Consensus FASTAs                                      Merged VCFs
                  (→ external RAxML →                                              │
                    topologies/data/ReSeq_phylos/)                                 │
                                                                                   ▼
                                                                  9a_fbranch_speciesLevel  (Dsuite)
                                                                  9b_fbranch_sectionLevel  (Dsuite)
                                                                                   │
                                                                                   ▼
                                                                  fbranch_interp/data/
```

The `a` / `b` suffix on numbered steps denotes the two reference genomes the pipeline is run against in parallel: **`a` = Q. alba**, **`b` = Q. variabilis (Qvar)**.

---

## Step-by-Step

| Step | Script(s) | Tool | Purpose |
|------|-----------|------|---------|
| **0** | [`0_download_SRA_oakphylo2025.sh`](0_download_SRA_oakphylo2025.sh) | sra-toolkit, gnu-parallel | Download raw FASTQ from SRA accessions |
| **00** | [`00_zip.sh`](00_zip.sh) | gzip, gnu-parallel | Compress raw FASTQ files |
| **1** | [`1_pretreat_SRR18459034.sh`](1_pretreat_SRR18459034.sh) | skewer | One-off skewer trim for SRR18459034 (overrepresented adapters in `1_adapters_and_overRepresented.fa`) |
| **1a** | [`1a_run_fastp_all.sh`](1a_run_fastp_all.sh) | fastp, fastqc | Adapter trimming + per-read QC for all samples |
| **2a/2b** | [`2a_aliging_reads.Qalba.sh`](2a_aliging_reads.Qalba.sh), [`2b_aliging_reads.Qvar.sh`](2b_aliging_reads.Qvar.sh), [`2a_aliging_reads.unpaired.Qalba.sh`](2a_aliging_reads.unpaired.Qalba.sh) | bwa mem, samtools | Align trimmed reads to Q. alba / Q. variabilis reference; SE variant for unpaired reads |
| **3a/3b** | [`3a_sort_sams.sh`](3a_sort_sams.sh), [`3b_sort_sams.sh`](3b_sort_sams.sh) | samtools sort | Coordinate-sort SAM → BAM |
| **4a/4b** | [`4a_markduplicates.Qalba.sh`](4a_markduplicates.Qalba.sh), [`4b_markduplicates.Qvar.sh`](4b_markduplicates.Qvar.sh) | Picard MarkDuplicates | Flag PCR duplicates |
| **4c** | [`4c_samtools_depth.sh`](4c_samtools_depth.sh) | samtools depth | Per-sample coverage stats (QC) |
| **5a/5b** | [`5a_mpileup_call_Qalba.sh`](5a_mpileup_call_Qalba.sh), [`5b_mpileup_call_Qvar.sh`](5b_mpileup_call_Qvar.sh) | bcftools mpileup + call | Variant calling (`--skip-indels`, `--min-BQ 15`, `--min-MQ 15`, `--gvcf 10`) |
| **6a/6b** | [`6a_filter_index_Qalba.sh`](6a_filter_index_Qalba.sh), [`6b_filter_index_Qvar.sh`](6b_filter_index_Qvar.sh) | bcftools filter, index | Mask genotypes with `FORMAT/DP < 8` (`DPmin8`); index |
| **7a/7b** | [`7a_consensus_alba.sh`](7a_consensus_alba.sh), [`7b_consensus_var.sh`](7b_consensus_var.sh) | bcftools consensus | Build per-sample consensus FASTAs (`--haplotype I --absent '?' --missing 'n' --mark-del '-'`) |
| **8** | [`8_merge_calls.sh`](8_merge_calls.sh) | bcftools merge | Merge per-sample VCFs into a single multi-sample VCF per reference (chromosomes only) |
| **9a** | [`9a_fbranch_speciesLevel/`](9a_fbranch_speciesLevel/) | Dsuite (Dtrios + Fbranch) | Species-level *f*-branch on the merged Qalba and Qvar VCFs |
| **9b** | [`9b_fbranch_sectionLevel/`](9b_fbranch_sectionLevel/) | Dsuite (Dtrios + Fbranch) | Section-level *f*-branch (samples grouped by *Quercus* section) |

Each `.sh` SLURM submitter loads modules (`ml bwa`, `ml samtools`, etc.) and runs `parallel -j N < <step>.txt`. The corresponding `.txt` files contain one shell command per sample/job; they are committed alongside the submitters as the canonical record of which samples were processed.

---

## Subdirectories

| Path | Contents |
|------|----------|
| [`python_scripts/`](python_scripts/) | Helper scripts: [`trim_unplaced_scaffolds.py`](python_scripts/trim_unplaced_scaffolds.py) (drop non-`Chr` scaffolds from FASTA), [`average_samtools.depth.py`](python_scripts/average_samtools.depth.py) (mean depth from `samtools depth` output), [`consensus_seq_explorer.py`](python_scripts/consensus_seq_explorer.py) + [`consensus_seq_explorer_formatter.py`](python_scripts/consensus_seq_explorer_formatter.py) (count `?`/`n`/`N`/`-`/other characters in consensus FASTAs), [`list_to_2_column.py`](python_scripts/list_to_2_column.py) (utility) |
| [`stats/`](stats/) | QC outputs: `consensus_stats.csv`/`.list` (character composition of consensus FASTAs), `Genome_wide_average_depth.txt`, `fastp.{html,json}` |
| [`9a_fbranch_speciesLevel/`](9a_fbranch_speciesLevel/) | Species-level *f*-branch run; produces `Results_fBranch.oakphylo2025.{Qalba,Qvar}.merged_calls.2026_02_06` consumed by [`../fbranch_interp/`](../fbranch_interp/) |
| [`9b_fbranch_sectionLevel/`](9b_fbranch_sectionLevel/) | Section-level *f*-branch run; produces `Results_sections_fBranch.oakphylo2025.Qalba.merged_calls.2026_03_23` |

---

## Key Files Outside the Numbered Steps

- [`1_adapters_and_overRepresented.fa`](1_adapters_and_overRepresented.fa) — adapter and overrepresented-sequence FASTA used by skewer in step 1.
- `0_download_SRA_oakphylo2025.txt`, `1a_run_fastp_all.txt`, … — job lists referenced by `parallel` (one command per line per sample). Reference data sit in `/N/project/oakphylo2025/` on the IU HPC.

---

## Software Dependencies

`bwa`, `samtools`, `bcftools`, `picard` (v2.27.3), `fastp`, `fastqc`, `skewer-0.2.2`, `sra-toolkit`, `gnu-parallel`, Python 3, Java (for Picard), `Dsuite` (built locally at `9a_fbranch_speciesLevel/Dsuite/Build/Dsuite` on the HPC).

---

## Filtering / Calling Choices Worth Knowing

- mpileup: `--skip-indels --min-BQ 15 --min-MQ 15`; calling with `bcftools call -m --gvcf 10`.
- Genotype mask: any genotype with `FORMAT/DP < 8` is set to missing (`DPmin8` filename suffix).
- Consensus: `bcftools consensus --haplotype I` (first allele), missing → `n`, absent → `?`, deletions → `-`.
- Step 8 merge restricts to the 12 chromosome-level scaffolds (`<Ref>_Chr01`–`Chr12`); unplaced scaffolds are excluded.

---
*This README was written by Claude Code (claude.ai/code) with Andrew Hipp's permission — 2026-05-06.*
