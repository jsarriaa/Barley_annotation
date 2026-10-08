#!/bin/bash
# Script to configure Mikado for transcriptome assembly.

# --- Define File Paths and Parameters ---
GENOTYPE="GDB_136"
BLASTFASTA="uniref50.fasta"

# Input files
INPUT_LIST="transcripts/${GENOTYPE}.mikado.tbl"
INPUT_GENOME="data/${GENOTYPE}.fa"
INPUT_JUNCTIONS="portcullis/${GENOTYPE}.junctions.bed"

# Output files
OUTPUT_YAML="transcripts/${GENOTYPE}.mikado.config.yaml"
OUTPUT_DIR="transcripts"

# Mikado parameters
MODE="permissive"
SCORE_FILE="plant.yaml"

# Logging
LOG_FILE="logs/${GENOTYPE}.mikado.transcripts_mik.config.log"

# --- Main Command ---

# Create the logs directory if it doesn't exist
mkdir -p logs

echo "Configuring Mikado for ${GENOTYPE}." | tee -a "$LOG_FILE"
echo "Input table: ${INPUT_LIST}" | tee -a "$LOG_FILE"
echo "Reference genome: ${INPUT_GENOME}" | tee -a "$LOG_FILE"
echo "Junctions BED: ${INPUT_JUNCTIONS}" | tee -a "$LOG_FILE"
echo "Output YAML: ${OUTPUT_YAML}" | tee -a "$LOG_FILE"
echo "--- Starting Mikado configuration ---" | tee -a "$LOG_FILE"

# Check if required input files exist
if [ ! -f "$INPUT_LIST" ]; then
    echo "ERROR: Mikado input table not found: $INPUT_LIST" | tee -a "$LOG_FILE"
    exit 1
fi

if [ ! -f "$INPUT_GENOME" ]; then
    echo "ERROR: Reference genome FASTA not found: $INPUT_GENOME" | tee -a "$LOG_FILE"
    exit 1
fi

if [ ! -f "$INPUT_JUNCTIONS" ]; then
    echo "ERROR: Junctions BED file not found: $INPUT_JUNCTIONS" | tee -a "$LOG_FILE"
    exit 1
fi

# Run mikado configure and redirect all output to the log file
mikado configure \
    --list "${INPUT_LIST}" \
    --reference "${INPUT_GENOME}" \
    --mode "${MODE}" \
    --scoring "${SCORE_FILE}" \
    --copy-scoring "${SCORE_FILE}" \
    -bt "${BLASTFASTA}" \
    --junctions "${INPUT_JUNCTIONS}" \
    -od "${OUTPUT_DIR}" \
    "${OUTPUT_YAML}" &>> "$LOG_FILE"

# Check the exit status of the mikado command
if [ $? -eq 0 ]; then
    echo "--- Mikado configuration completed successfully for ${GENOTYPE} ---" | tee -a "$LOG_FILE"
    echo "Configuration YAML saved to: ${OUTPUT_YAML}" | tee -a "$LOG_FILE"
else
    echo "--- ERROR: Mikado configuration failed for ${GENOTYPE} ---" | tee -a "$LOG_FILE"
    echo "Please check the log file for details: ${LOG_FILE}" | tee -a "$LOG_FILE"
    exit 1
fi

