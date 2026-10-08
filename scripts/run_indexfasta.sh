#!/bin/bash

# --- Configuration for fasta_idx ---
GENOME_ID="GDB_136"
INPUT_FASTA="data/GDB_136.fa"
LOG_DIR="./logs"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Log file path
LOG_FILE="${LOG_DIR}/${GENOME_ID}.fastaidx.log"

# --- Main Command for fasta_idx ---

echo "Building FASTA index for ${GENOME_ID}"
echo "Input FASTA: ${INPUT_FASTA}"
echo "Log file: ${LOG_FILE}"
echo "--- Starting FASTA indexing ---"

# Check if the input FASTA file exists
if [ ! -f "$INPUT_FASTA" ]; then
    echo "ERROR: Input FASTA file not found: $INPUT_FASTA" | tee -a "$LOG_FILE"
    exit 1
fi

# Run samtools faidx and redirect all output to the log file
samtools faidx \
  "$INPUT_FASTA" \
  &> "$LOG_FILE"

# Check the exit status of the samtools command
if [ $? -eq 0 ]; then
    echo "--- FASTA indexing completed successfully for ${GENOME_ID} ---" | tee -a "$LOG_FILE"
else
    echo "--- ERROR: FASTA indexing failed for ${GENOME_ID} ---" | tee -a "$LOG_FILE"
    echo "Please check the log file for details: $LOG_FILE" | tee -a "$LOG_FILE"
    exit 1
fi
