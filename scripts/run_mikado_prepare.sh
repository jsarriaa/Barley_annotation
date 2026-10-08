#!/bin/bash
# Script to prepare Mikado for transcriptome assembly.

# --- Define File Paths and Parameters ---
GENOTYPE="GDB_136"

# Input file
INPUT_YAML="transcripts/${GENOTYPE}.mikado.config.yaml"

# Output files
OUTPUT_GTF="transcripts/${GENOTYPE}_mikado_prepared.gtf"
OUTPUT_FASTA="transcripts/${GENOTYPE}_mikado_prepared.fasta"

# Mikado parameters
NUM_THREADS=32

# Logging
LOG_FILE="logs/${GENOTYPE}.mikado.transcripts_mik.prepare.log"

# --- Main Command ---

echo "Preparing Mikado run for ${GENOTYPE}." | tee -a "$LOG_FILE"
echo "Input YAML: ${INPUT_YAML}" | tee -a "$LOG_FILE"
echo "Output GTF: ${OUTPUT_GTF}" | tee -a "$LOG_FILE"
echo "Output FASTA: ${OUTPUT_FASTA}" | tee -a "$LOG_FILE"
echo "Threads: ${NUM_THREADS}" | tee -a "$LOG_FILE"
echo "--- Starting Mikado prepare ---" | tee -a "$LOG_FILE"

# Check if the input YAML file exists
if [ ! -f "$INPUT_YAML" ]; then
    echo "ERROR: Mikado config YAML not found: $INPUT_YAML" | tee -a "$LOG_FILE"
    exit 1
fi

# Run mikado prepare and redirect all output to the log file
mikado prepare \
    -p "$NUM_THREADS" \
    --out "$OUTPUT_GTF" \
    --out_fasta "$OUTPUT_FASTA" \
    --json-conf "$INPUT_YAML" &>> "$LOG_FILE"

# Check the exit status of the mikado command
if [ $? -eq 0 ]; then
    echo "--- Mikado prepare completed successfully for ${GENOTYPE} ---" | tee -a "$LOG_FILE"
    echo "Prepared files saved to: ${OUTPUT_GTF} and ${OUTPUT_FASTA}" | tee -a "$LOG_FILE"
else
    echo "--- ERROR: Mikado prepare failed for ${GENOTYPE} ---" | tee -a "$LOG_FILE"
    echo "Please check the log file for details: ${LOG_FILE}" | tee -a "$LOG_FILE"
    exit 1
fi
