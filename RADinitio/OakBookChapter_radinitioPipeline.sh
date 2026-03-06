# Pipeline for RADinitio RAD data simulation for book chapter on whole genome data
# by. Kieran Althaus

#!/bin/bash

# Set directories
GENOMES_DIR="/mnt/USERS/oakphylo25/simRAD/data/qalba/"
POPULATION_OUT_DIR="/mnt/USERS/oakphylo25/simRAD/out/qalba/make_population_out"
LIBRARY_OUT_DIR="/mnt/USERS/oakphylo25/simRAD/out/qalba/make_library_out"

# Define modeling parameters for --make-population
min_seq_len=1000000
n_pops=1
pop_eff_size=1
n_seq_indv=1
enz="PstI"
pop_mig_rate=0

# Define modeling parameters for --make-library-seq
chromosomes="data/chrom_list.txt"
library_type="sdRAD"
insert_mean=450
insert_stdev=50
pcr_model="inheff"
pcr_cycles=12
coverage=30
read_length=100
read_out_fmt="fastq"

# Create output directories if they don't exist mkdir -p "$POPULATION_OUT_DIR"
mkdir -p "$LIBRARY_OUT_DIR"

echo "Starting RADinitio processing..."
echo "Genome directory: $GENOMES_DIR"
echo "Population output directory: $POPULATION_OUT_DIR"
echo "Library output directory: $LIBRARY_OUT_DIR"
echo ""

# Step 1: Run --make-population for each genome
echo "=== STEP 1: Running --make-population for each genome ==="
for genome_file in "$GENOMES_DIR"/*Qalba.fasta.gz; do
    # Check if files exist (in case no .fa.gz files are found)
    if [ ! -f "$genome_file" ]; then
        echo "No Qalba.fasta files found in $GENOMES_DIR"
        exit 1
    fi
    
    # Extract genome name (remove path and .fa.gz extension)
    genome_name=$(basename "$genome_file" .Qalba.fasta.gz)
    
    # Create genome-specific output directory
    genome_pop_out="$POPULATION_OUT_DIR/$genome_name"
    mkdir -p "$genome_pop_out"
    
    echo "Processing genome: $genome_name"
    echo "Input file: $genome_file"
    echo "Output directory: $genome_pop_out"
    
    # Run radinitio --make-population
    radinitio --make-population \
        --genome "$genome_file" \
        --min-seq-len "$min_seq_len" \
        --out-dir "$genome_pop_out" \
        --n-pops "$n_pops" \
        --pop-eff-size "$pop_eff_size" \
        --n-seq-indv "$n_seq_indv" \
        --enz "$enz" \
        --pop-mig-rate "$pop_mig_rate"
    
    # Check if the command was successful
    if [ $? -eq 0 ]; then
        echo "✓ Successfully completed --make-population for $genome_name"
    else
        echo "✗ Error running --make-population for $genome_name"
        exit 1
    fi
    echo ""
done

# echo "=== STEP 1 COMPLETED: All --make-population jobs finished ==="
# echo ""

# Step 2: Run --make-library-seq for each genome
echo "=== STEP 2: Running --make-library-seq for each genome ==="
for genome_file in "$GENOMES_DIR"/*.Qalba.fasta.gz; do
    # Extract genome name (remove path and .fa.gz extension)
    genome_name=$(basename "$genome_file" .Qalba.fasta.gz)
    
    # Set up directories
    genome_pop_out="$POPULATION_OUT_DIR/$genome_name"
    genome_lib_out="$LIBRARY_OUT_DIR/$genome_name"
    mkdir -p "$genome_lib_out"
    
    # Get chromosome list (assuming you want all chromosomes)
    # You may need to modify this based on your specific needs
    
    echo "Processing genome: $genome_name"
    echo "Input file: $genome_file"
    echo "Population directory: $genome_pop_out"
    echo "Library output directory: $genome_lib_out"
    
    # Run radinitio --make-library-seq
    radinitio --make-library-seq \
        --genome "$genome_file" \
        --out-dir "$genome_lib_out" \
        --make-pop-sim-dir "$genome_pop_out" \
        --library-type "$library_type" \
        --enz "$enz" \
        --insert-mean "$insert_mean" \
        --insert-stdev "$insert_stdev" \
        --pcr-model "$pcr_model" \
        --pcr-cycles "$pcr_cycles" \
        --coverage "$coverage" \
        --read-length "$read_length" \
        --read-out-fmt "$read_out_fmt"
    
    # Check if the command was successful
    if [ $? -eq 0 ]; then
        echo "✓ Successfully completed --make-library-seq for $genome_name"
    else
        echo "✗ Error running --make-library-seq for $genome_name"
        exit 1
    fi
    echo ""
done

echo "=== STEP 2 COMPLETED: All --make-library-seq jobs finished ==="
echo ""
echo "RADinitio processing completed successfully for all genomes!"
echo ""
echo "Results:"
echo "  Population data: $POPULATION_OUT_DIR"
echo "  Library data: $LIBRARY_OUT_DIR"