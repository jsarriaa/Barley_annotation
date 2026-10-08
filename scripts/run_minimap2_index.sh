#!/bin/bash

# --- Configuration for minimap2_idx ---
GENOME_ID="GDB_136"
INPUT_FASTA="data/GDB_136.fa"

OUTPUT_DIR="./GDB_136.minimap2"
LOG_DIR="./logs"

# Ensure output and log directories exist
mkdir -p "$OUTPUT_DIR"
mkdir -p "$LOG_DIR"

# Output index file path (matches {genome}/{genome}.mmi)
OUTPUT_MMI="${OUTPUT_DIR}/${GENOME_ID}.mmi"

# Log file path
LOG_FILE="${LOG_DIR}/${GENOME_ID}.minimapidx.log"

# --- minimap2 Parameters ---
NUM_THREADS=16
MEM_LIMIT_INDEX="16G" # From original repo values

# --- Main Command for minimap2_idx ---

echo "Building minimap2 index for ${GENOME_ID} @ ${NUM_THREADS} threads with memory limit ${MEM_LIMIT_INDEX}"
echo "Input FASTA: ${INPUT_FASTA}"
echo "Output MMI: ${OUTPUT_MMI}"
echo "Log file: ${LOG_FILE}"
echo "--- Starting minimap2 indexing ---"

# Check if the input FASTA file exists
if [ ! -f "$INPUT_FASTA" ]; then
    echo "ERROR: Input FASTA file not found: $INPUT_FASTA" | tee -a "$LOG_FILE"
    exit 1
fi

# Run minimap2 and redirect all output to the log file
minimap2 \
  -I "$MEM_LIMIT_INDEX" \
  -t "$NUM_THREADS" \
  -d "$OUTPUT_MMI" \
  "$INPUT_FASTA" \
  &> "$LOG_FILE"

# Check the exit status of the minimap2 command
if [ $? -eq 0 ]; then
    echo "--- Minimap2 indexing completed successfully for ${GENOME_ID} ---" | tee -a "$LOG_FILE"
    echo "Index saved to: $OUTPUT_MMI" | tee -a "$LOG_FILE"
else
    echo "--- ERROR: Minimap2 indexing failed for ${GENOME_ID} ---" | tee -a "$LOG_FILE"
    echo "Please check the log file for details: $LOG_FILE" | tee -a "$LOG_FILE"
    exit 1
fi
