#!/bin/bash

# Concatenate multi-chromosome FASTA files into single sequences and rename by filename

show_help() {
    cat << EOF
Usage: ./concatenate_fasta.sh [OPTIONS] <input_directory>

Concatenate multi-chromosome FASTA files and rename sequences by filename.

OPTIONS:
    -h, --help              Show this help message
    -o, --output DIR        Output directory (default: same as input)
    -p, --pattern PATTERN   File pattern to match (default: *.fasta, *.fa, *.fna)
    -v, --verbose           Print detailed information
    --inplace              Modify files in place (overwrite originals)

EXAMPLES:
    # Process all FASTA files in a directory
    ./concatenate_fasta.sh /path/to/fastas

    # Save output to a different directory
    ./concatenate_fasta.sh /path/to/fastas -o /path/to/output

    # Modify files in place
    ./concatenate_fasta.sh /path/to/fastas --inplace

    # Match specific file pattern
    ./concatenate_fasta.sh /path/to/fastas -p "*.aligned"

    # Verbose output
    ./concatenate_fasta.sh /path/to/fastas -v

EOF
}

# Default values
INPUT_DIR=""
OUTPUT_DIR=""
PATTERN=""
VERBOSE=0
INPLACE=0

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -o|--output)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -p|--pattern)
            PATTERN="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=1
            shift
            ;;
        --inplace)
            INPLACE=1
            shift
            ;;
        -*)
            echo "Error: Unknown option $1"
            show_help
            exit 1
            ;;
        *)
            INPUT_DIR="$1"
            shift
            ;;
    esac
done

# Validate input directory
if [[ -z "$INPUT_DIR" ]]; then
    echo "Error: input_directory is required"
    show_help
    exit 1
fi

if [[ ! -d "$INPUT_DIR" ]]; then
    echo "Error: $INPUT_DIR is not a valid directory"
    exit 1
fi

# Set output directory
if [[ $INPLACE -eq 1 ]]; then
    OUTPUT_DIR="$INPUT_DIR"
elif [[ -z "$OUTPUT_DIR" ]]; then
    OUTPUT_DIR="$INPUT_DIR"
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Find FASTA files
if [[ -z "$PATTERN" ]]; then
    mapfile -t FASTA_FILES < <(find "$INPUT_DIR" -maxdepth 1 \( -name "*.fasta" -o -name "*.fa" -o -name "*.fna" \) | sort)
else
    mapfile -t FASTA_FILES < <(find "$INPUT_DIR" -maxdepth 1 -name "$PATTERN" | sort)
fi

if [[ ${#FASTA_FILES[@]} -eq 0 ]]; then
    echo "No FASTA files found in $INPUT_DIR"
    exit 1
fi

echo "Found ${#FASTA_FILES[@]} FASTA file(s)"
echo ""

PROCESSED=0
FAILED=0

# Process each FASTA file
for FASTA_FILE in "${FASTA_FILES[@]}"; do
    FILENAME=$(basename "$FASTA_FILE")
    BASENAME="${FILENAME%.*}"
    
    echo "Processing: $FILENAME"
    
    # Create temporary file
    TEMP_FILE=$(mktemp)
    OUTPUT_FILE="$OUTPUT_DIR/$FILENAME"
    
    # Extract and concatenate sequences, rename header
    {
        echo ">$BASENAME"
        grep -v '^>' "$FASTA_FILE" | tr -d '\n'
        echo ""
    } > "$TEMP_FILE"
    
    # Format output to 80 chars per line
    {
        head -1 "$TEMP_FILE"
        tail -1 "$TEMP_FILE" | sed 's/.\{80\}/&\n/g'
    } > "$OUTPUT_FILE"
    
    rm "$TEMP_FILE"
    
    if [[ $VERBOSE -eq 1 ]]; then
        SEQ_COUNT=$(grep -c '^>' "$FASTA_FILE")
        SEQ_LENGTH=$(grep -v '^>' "$OUTPUT_FILE" | tr -d '\n' | wc -c)
        echo "  - Found $SEQ_COUNT sequence(s)"
        echo "  - Concatenated length: $SEQ_LENGTH bp"
    fi
    
    echo "  ✓ Output: $FILENAME"
    echo ""
    
    ((PROCESSED++))
done

echo "Summary: $PROCESSED processed, $FAILED failed"