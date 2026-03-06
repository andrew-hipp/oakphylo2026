#!/usr/bin/env python3

"""
Split a multiple sequence alignment (MSA) into individual FASTA files.
Each output file is named after the sequence ID.
"""

import argparse
import sys
import gzip
from pathlib import Path


def split_msa(input_file, output_dir, prefix="", suffix=""):
    """
    Split an MSA file into individual FASTA files.
    
    Args:
        input_file: Path to input MSA file
        output_dir: Directory to save individual FASTA files
        prefix: Optional prefix for output filenames
        suffix: Optional suffix for output filenames
    
    Returns:
        Number of sequences written
    """
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    count = 0
    current_id = None
    current_seq = []
    
    # Determine if file is gzipped
    is_gzipped = str(input_file).endswith('.gz')
    
    try:
        # Open file with appropriate method
        if is_gzipped:
            file_handle = gzip.open(input_file, 'rt')
        else:
            file_handle = open(input_file, 'r')
        
        with file_handle as f:
            for line in f:
                line = line.rstrip('\n')
                
                if line.startswith('>'):
                    # Write previous sequence if it exists
                    if current_id is not None:
                        write_sequence(output_dir, current_id, current_seq, prefix, suffix)
                        count += 1
                    
                    # Extract sequence ID (first word after '>')
                    current_id = line[1:].split()[0]
                    current_seq = []
                
                else:
                    # Append to current sequence
                    current_seq.append(line)
            
            # Write the last sequence
            if current_id is not None:
                write_sequence(output_dir, current_id, current_seq, prefix, suffix)
                count += 1
    
    except FileNotFoundError:
        print(f"Error: Input file '{input_file}' not found!", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error reading file: {e}", file=sys.stderr)
        sys.exit(1)
    
    return count


def write_sequence(output_dir, seq_id, seq_lines, prefix, suffix):
    """Write a sequence to an individual FASTA file."""
    filename = f"{prefix}{seq_id}{suffix}.fasta"
    output_path = output_dir / filename
    
    try:
        with open(output_path, 'w') as f:
            f.write(f">{seq_id}\n")
            for line in seq_lines:
                f.write(f"{line}\n")
    except Exception as e:
        print(f"Error writing file {output_path}: {e}", file=sys.stderr)


def main():
    parser = argparse.ArgumentParser(
        description="Split a multiple sequence alignment (MSA) into individual FASTA files",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Basic usage
  python3 split_msa.py input_msa.fasta

  # Specify output directory
  python3 split_msa.py input_msa.fasta -o ./sequences/

  # Add prefix and suffix to output filenames
  python3 split_msa.py input_msa.fasta -o ./sequences/ --prefix sample_ --suffix _seq
        """
    )
    
    parser.add_argument('input_file', help='Input MSA FASTA file')
    parser.add_argument('-o', '--output', dest='output_dir', default='.',
                        help='Output directory for individual FASTA files (default: current directory)')
    parser.add_argument('--prefix', default='',
                        help='Prefix to add to output filenames')
    parser.add_argument('--suffix', default='',
                        help='Suffix to add to output filenames (before .fasta)')
    
    args = parser.parse_args()
    
    print(f"Reading MSA from: {args.input_file}")
    count = split_msa(args.input_file, args.output_dir, args.prefix, args.suffix)
    
    print(f"✓ Successfully split MSA into {count} individual FASTA files")
    print(f"✓ Output files saved in: {args.output_dir}")


if __name__ == '__main__':
    main()