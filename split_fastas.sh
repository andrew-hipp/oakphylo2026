#!/bin/bash

# Script to split a multiple sequence alignment (MSA) into individual FASTA files
# Usage: ./split_msa.sh <input_msa.fasta> [output_directory]

set -e

# Check if input file is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <input_msa.fasta> [output_directory]"
    echo ""
    echo "This script splits an MSA into individual FASTA files."
    echo "Each output file is named after the sequence ID."
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_DIR="${2:-.}"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found!"
    exit 1
fi

# Determine if file is gzipped and set up appropriate reader
if [[ "$INPUT_FILE" == *.gz ]]; then
    FILE_READER="zcat"
else
    FILE_READER="cat"
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Counter for tracking sequences
count=0

# Read through the FASTA file and extract each sequence
$FILE_READER "$INPUT_FILE" | awk -v output_dir="$OUTPUT_DIR" '
BEGIN {
    seq_id = ""
    seq = ""
}
/^>/ {
    # If we have a previous sequence, write it out
    if (seq_id != "") {
        filename = output_dir "/" seq_id ".fasta"
        print ">" seq_id > filename
        print seq >> filename
        close(filename)
    }
    # Extract the sequence ID (first word after >)
    seq_id = substr($0, 2)
    gsub(/ .*/, "", seq_id)  # Remove everything after first space
    seq = ""
}
!/^>/ {
    # Append sequence line
    seq = seq $0
}
END {
    # Write the last sequence
    if (seq_id != "") {
        filename = output_dir "/" seq_id ".fasta"
        print ">" seq_id > filename
        print seq >> filename
        close(filename)
    }
}
' "$INPUT_FILE"

# Count the output files
file_count=$(ls -1 "$OUTPUT_DIR"/*.fasta 2>/dev/null | wc -l)

echo "✓ Successfully split MSA into $file_count individual FASTA files"
echo "✓ Output files saved in: $OUTPUT_DIR"