#!/bin/bash

# Ensure seqtk is available (checks if the user activated the correct environment)
if ! command -v seqtk &> /dev/null; then
    echo "Error: 'seqtk' command not found."
    echo "Please make sure you have activated the correct Conda environment (e.g., 'conda activate pananno_jsarria') before running this script."
    exit 1
fi

# Set the output directory to the current directory
OUTPUT_DIR="."
echo "Output directory: $OUTPUT_DIR"

# Define the final combined filename (.fa prevents it from catting itself during future runs)
COMBINED_FASTA="combined_mrna_transcripts.fa"

# Clean up old combined file if it exists from a previous run
[ -f "$COMBINED_FASTA" ] && rm "$COMBINED_FASTA"

# Loop through all the gzipped FASTQ files
echo "Starting file processing..."
for fastq_file in *.fq.gz; do
    # Safety check in case there are no .fq.gz files in the folder
    [ -e "$fastq_file" ] || { echo "No .fq.gz files found!"; exit 1; }

    echo "Processing $fastq_file..."
    
    # Define the output FASTA filename
    fasta_file="${OUTPUT_DIR}/${fastq_file%.fq.gz}.fasta"
    
    # Use seqtk to convert the gzipped FASTQ to a FASTA file
    zcat "$fastq_file" | seqtk seq -a - > "$fasta_file"
    
    # Check for success
    if [ $? -ne 0 ]; then
        echo "Error processing $fastq_file. Skipping this file."
    else
        echo "Successfully created $fasta_file"
    fi
done

# After the loop, combine all the individual FASTA files into one master file
echo "Combining all individual FASTA files..."
cat "${OUTPUT_DIR}"/*.fasta > "$COMBINED_FASTA"

# Check if the final file was created and is not empty
if [ -s "$COMBINED_FASTA" ]; then
    echo "Successfully created combined file: $COMBINED_FASTA"
    echo "The file contains this many sequences:"
    grep -c '^>' "$COMBINED_FASTA" # Count the number of sequences
else
    echo "Error: The combined FASTA file was not created or is empty. Please check the logs."
fi

echo "Script finished."
