#!/bin/bash

# Define your tools and directories
SCRIPT="EDTA.pl"
GENOME_DIR="genome_by_contigs"
OUT_DIR="EDTA"
LOG_DIR="logs/EDTA"

# Create the output and log folders if they don't exist yet
mkdir -p "$OUT_DIR"
mkdir -p "$LOG_DIR"

# Get the absolute path to the genome directory 
# (Needed because we will be changing directories inside the loop)
ABS_GENOME_DIR="$PWD/$GENOME_DIR"

# Limit concurrent jobs to save the server (2 jobs * 16 threads = 32 threads)
MAX_JOBS=2

echo "Starting EDTA pipeline for ALL fasta files..."
echo " - Outputs will be saved to: $OUT_DIR/"
echo " - Logs will be saved to:    $LOG_DIR/"

for fasta in "$ABS_GENOME_DIR"/*.fasta; do
    # Skip if no files are found
    [ -e "$fasta" ] || continue

    # Extract just the filename
    base_name=$(basename "$fasta" .fasta)
    
    echo "Submitting EDTA.pl for $base_name..."
    
    # Run in a background subshell: 
    # 1. 'cd' into the EDTA folder so all output generates there
    # 2. Run the command using the absolute path to the fasta file
    # 3. Send the log file up one level into the logs/EDTA folder
    (
        cd "$OUT_DIR" || exit
        "$SCRIPT" --genome "$fasta" --anno 1 --overwrite 1 --threads 16 \
            > "../$LOG_DIR/EDTA_${base_name}.log" 2>&1
    ) &
        
    # Concurrency controller
    while [[ $(jobs -r -p | wc -l) -ge $MAX_JOBS ]]; do
        wait -n
    done
done

# Wait for the last batch to finish
wait

echo "All EDTA.pl jobs have completed successfully."
