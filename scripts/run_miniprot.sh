#!/bin/bash

# --- Configuration ---
GENOME_ID="GDB_136"
INPUT_FASTA="data/GDB_136.fa"

OUTPUT_DIR="./miniprot"
LOG_DIR="./logs"

# Ensure output and log directories exist
mkdir -p "$OUTPUT_DIR"
mkdir -p "$LOG_DIR"

# Output index file path (matches {genome}/{genome}.mpi)
OUTPUT_MPI="${OUTPUT_DIR}/${GENOME_ID}.mpi"

# Log file paths

LOG_FILE="${LOG_DIR}/${GENOME_ID}_miniprotidx.log"

# --- Miniprot Parameters ---
NUM_THREADS=16

# --- Main Command ---

echo "Building miniprot index for ${GENOME_ID} @ ${NUM_THREADS} threads."
echo "Input FASTA: ${INPUT_FASTA}"
echo "Output MPI: ${OUTPUT_MPI}"
echo "Log file: ${LOG_FILE}"
echo "--- Starting miniprot indexing ---"

# Check if the input FASTA file exists
if [ ! -f "$INPUT_FASTA" ]; then
    echo "ERROR: Input FASTA file not found: $INPUT_FASTA" | tee -a "$LOG_FILE"
    exit 1
fi

# Run miniprot and redirect all output to the log file
miniprot \
  -t "$NUM_THREADS" \
  -d "$OUTPUT_MPI" \
  "$INPUT_FASTA" \
  &> "$LOG_FILE" # This redirects both stdout and stderr to the log file

# Check the exit status of the miniprot command
if [ $? -eq 0 ]; then
    echo "--- Miniprot indexing completed successfully for ${GENOME_ID} ---" | tee -a "$LOG_FILE"
    echo "Index saved to: $OUTPUT_MPI" | tee -a "$LOG_FILE"
else
    echo "--- ERROR: Miniprot indexing failed for ${GENOME_ID} ---" | tee -a "$LOG_FILE"
    echo "Please check the log file for details: $LOG_FILE" | tee -a "$LOG_FILE"
    exit 1
fi
