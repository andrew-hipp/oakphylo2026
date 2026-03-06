# oakphylo_bookch_2026
Contains main analysis script and helper scripts to run RADinitio with whole genome data

## OakBookChapter_radinitioPipeline.sh
The primary RADinitio pipeline. Takes as input a directory containing your reference genome and the names of two output directories the script will generate.

## parse_fastas.sh
Script used to concatonate multi-chromosome FASTA files into a single sequence and rename by original file name

## split_fastas.py
Split a multiple sequence alignment (MSA) into individual FASTA files. Each output file is named after the sequence ID.

## split_fastas.sh
The same as above, but written as bash script.

## removeGapMSA.py
Removes all columns from a multiple sequence alignment that contains gaps (-) or missing data (?) in any sequence
