#!/usr/bin/env python3
"""
Remove all columns from a multiple sequence alignment that contain gaps (-) or missing data (?) in any sequence.
Optimized for large alignments.
"""

import sys
import argparse
import gzip
from pathlib import Path

def open_file(filename, mode='r'):
    """
    Open file with automatic gzip detection based on extension.
    """
    if str(filename).endswith('.gz'):
        return gzip.open(filename, mode + 't', encoding='utf-8')
    else:
        return open(filename, mode, encoding='utf-8')

def find_gapped_positions(fasta_file):
    """
    First pass: identify all positions that contain gaps (-) or missing data (?) in any sequence.
    Returns a set of 0-based positions to remove.
    """
    gapped_positions = set()
    
    with open_file(fasta_file) as f:
        position = 0
        for line in f:
            line = line.strip()
            if line.startswith('>'):
                position = 0  # Reset position for new sequence
                continue
            
            # Check each character in the sequence line
            for i, char in enumerate(line):
                if char in ['-', '?']:  # Remove columns with hyphens or question marks
                    gapped_positions.add(position + i)
            
            position += len(line)
    
    return gapped_positions

def filter_sequences(input_file, output_file, gapped_positions):
    """
    Second pass: write sequences with gapped positions removed.
    """
    with open_file(input_file) as infile, open(output_file, 'w') as outfile:
        for line in infile:
            line = line.strip()
            
            if line.startswith('>'):
                outfile.write(line + '\n')
            else:
                # Filter out gapped positions
                filtered_seq = ''.join(char for i, char in enumerate(line) 
                                     if i not in gapped_positions)
                outfile.write(filtered_seq + '\n')

def process_large_msa(input_file, output_file):
    """
    Process large MSA files efficiently with two passes.
    """
    print(f"Processing {input_file}...")
    print("Pass 1: Identifying gapped positions...")
    
    gapped_positions = find_gapped_positions(input_file)
    
    print(f"Found {len(gapped_positions)} positions with gaps (-) or missing data (?) to remove")
    
    if not gapped_positions:
        print(f"No gaps (-) or missing data (?) found! Copying file as-is.")
        import shutil
        shutil.copy2(input_file, output_file)
        return
    
    print("Pass 2: Writing filtered sequences...")
    filter_sequences(input_file, output_file, gapped_positions)
    
    print(f"Filtered alignment written to {output_file}")
    
    # Show some stats
    original_length = max(gapped_positions) + 1 if gapped_positions else 0
    filtered_length = original_length - len(gapped_positions)
    print(f"Original alignment length: {original_length}")
    print(f"Filtered alignment length: {filtered_length}")
    print(f"Removed {len(gapped_positions)} columns containing gaps (-) or missing data (?)")

def main():
    parser = argparse.ArgumentParser(
        description="Remove columns with gaps (-) or missing data (?) from multiple sequence alignment",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument("input", help="Input FASTA file")
    parser.add_argument("-o", "--output", help="Output FASTA file", 
                       default="filtered_alignment.fasta")
    
    args = parser.parse_args()
    
    # Check if input file exists
    if not Path(args.input).exists():
        print(f"Error: Input file '{args.input}' not found")
        sys.exit(1)
    
    try:
        process_large_msa(args.input, args.output)
        print("Done!")
    except Exception as e:
        print(f"Error processing file: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()