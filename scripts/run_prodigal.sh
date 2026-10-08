#!/bin/bash
# Script to identify ORFs using Prodigal.

# --- Define File Paths and Parameters ---
GENOTYPE="GDB_136"

# Input file from a previous step (mikado prepare)
INPUT_FASTA="transcripts/${GENOTYPE}_mikado_prepared.fasta"

# Output file
OUTPUT_ORFS="transcripts/${GENOTYPE}_mikado_transcripts.orfs.gff"

# Logging
LOG_FILE="logs/${GENOTYPE}.prodigal.log"
# Error log (from Snakemake rule)
LOG_ERR="logs/${GENOTYPE}.prodigal.log.e"
# Output log (from Snakemake rule)
LOG_OUT="logs/${GENOTYPE}.prodigal.log.o"


# --- Main Command ---

echo "Identifying ORFs for ${GENOTYPE}." | tee -a "$LOG_FILE"
echo "Input FASTA: ${INPUT_FASTA}" | tee -a "$LOG_FILE"
echo "Output GFF: ${OUTPUT_ORFS}" | tee -a "$LOG_FILE"
echo "--- Starting Prodigal ---" | tee -a "$LOG_FILE"

# Check if the input FASTA file exists
if [ ! -f "$INPUT_FASTA" ]; then
    echo "ERROR: Input FASTA file not found: $INPUT_FASTA" | tee -a "$LOG_FILE"
    exit 1
fi

# Run prodigal with all output redirected to the logs
prodigal \
    -i "$INPUT_FASTA" \
    -g 1 \
    -o "$OUTPUT_ORFS" \
    -f gff 1> "$LOG_OUT" 2> "$LOG_ERR"

# Check the exit status of the prodigal command
if [ $? -eq 0 ]; then
    echo "--- Prodigal completed successfully for ${GENOTYPE} ---" | tee -a "$LOG_FILE"
    echo "ORFs saved to: ${OUTPUT_ORFS}" | tee -a "$LOG_FILE"
else
    echo "--- ERROR: Prodigal failed for ${GENOTYPE} ---" | tee -a "$LOG_FILE"
    echo "Please check the error log for details: ${LOG_ERR}" | tee -a "$LOG_FILE"
    exit 1
fi
