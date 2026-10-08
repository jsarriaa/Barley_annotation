#!/bin/bash
# Description: Extracts the Coding Sequences (CDS) from a GFF3 file using gffread.
# Requirements: gffread must be installed and available in the PATH.

# --- USER-DEFINED VARIABLES ---
GENOTYPE="GDB_136"

# --- FILE PATHS ---
# Input: Combined GFF3 file from the previous 'combine_helixer' step
INPUT_GFF="${GENOTYPE}/${GENOTYPE}.helixer.combined.gff3" 
# Input: Reference Genome FASTA
INPUT_GENOME="data/${GENOTYPE}.fa"
# Output: CDS FASTA file
OUTPUT_CDS="${GENOTYPE}/${GENOTYPE}.helixer.combined.cds.fa" 

LOG_FILE="logs/${GENOTYPE}.helixer.write_cds.log"

# --- SETUP AND INPUT CHECK ---
mkdir -p logs

if [ ! -f "$INPUT_GFF" ] || [ ! -f "$INPUT_GENOME" ]; then
    echo "ERROR: Required input files not found." | tee "$LOG_FILE"
    echo "GFF: $INPUT_GFF" | tee -a "$LOG_FILE"
    echo "Genome: $INPUT_GENOME" | tee -a "$LOG_FILE"
    exit 1
fi

echo "--- Starting CDS extraction using gffread for ${GENOTYPE} ---" | tee "$LOG_FILE"
echo "Output will be saved to: $OUTPUT_CDS" | tee -a "$LOG_FILE"

# --- CORE EXECUTION ---

# The gffread command: gffread -g <genome> <gff> -x <cds_output>
gffread \
    -g "${INPUT_GENOME}" \
    "${INPUT_GFF}" \
    -x "${OUTPUT_CDS}" \
    &>> "$LOG_FILE"

EXIT_CODE=$?

# --- FINAL REPORT ---
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "--- SUCCESS: CDS extraction completed ---" | tee -a "$LOG_FILE"
else
    echo "--- ERROR: CDS extraction failed (Exit Code: $EXIT_CODE). Check log: ${LOG_FILE}" | tee -a "$LOG_FILE"
    exit 1
fi

exit $EXIT_CODE
