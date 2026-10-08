#!/bin/bash

# --- Configuration Variables ---
GENOTYPE="GDB_136" 
RUN="RUN1"         
LOG_DIR="logs" # Define the log directory

# --- Input Files ---
INPUT_LOCI="mikado/${GENOTYPE}.mikado_refined_prediction.${RUN}.loci.gff3"
INPUT_GENOME="data/${GENOTYPE}.fa"

# --- Output Files ---
OUTPUT_CDS="${GENOTYPE}/${GENOTYPE}.mikado_refined_prediction.${RUN}.loci.cds.fa"

# --- Logging Setup ---
LOG_FILE="${LOG_DIR}/${GENOTYPE}.mikado.refined_prediction_mik.write_cds.log"

# Create the logs directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Start log file with a header
echo "--- Starting gffread CDS Extraction for ${GENOTYPE} (Run: ${RUN}) ---" > "$LOG_FILE"
echo "Start Time: $(date)" >> "$LOG_FILE"
echo "------------------------------------------------------------------" >> "$LOG_FILE"

# --- Execution ---

echo "Starting gffread to extract CDS for ${GENOTYPE}. Log redirected to ${LOG_FILE}"

# Check if input files exist before proceeding
if [[ ! -f "$INPUT_LOCI" ]] || [[ ! -f "$INPUT_GENOME" ]]; then
    echo "ERROR: Required input files not found! Check paths." >> "$LOG_FILE"
    echo "Loci GFF3: $INPUT_LOCI" >> "$LOG_FILE"
    echo "Genome FASTA: $INPUT_GENOME" >> "$LOG_FILE"
    exit 1
fi

# The gffread command:
# 1> >(tee -a $LOG_FILE) redirects stdout (1) to both the terminal and the log file (using tee -a)
# 2>&1 redirects stderr (2) to the same place as stdout (1)
(
  gffread \
    -g "${INPUT_GENOME}" \
    "${INPUT_LOCI}" \
    -x "${OUTPUT_CDS}"
) 1>> "$LOG_FILE" 2>&1

# Check the exit status of gffread and record in log
EXIT_STATUS=$?

echo "------------------------------------------------------------------" >> "$LOG_FILE"
echo "Finish Time: $(date)" >> "$LOG_FILE"

if [[ $EXIT_STATUS -eq 0 ]]; then
    echo "gffread completed successfully." >> "$LOG_FILE"
    echo "Successfully extracted CDS to ${OUTPUT_CDS}"
else
    echo "gffread failed with exit code $EXIT_STATUS." >> "$LOG_FILE"
    echo "gffread failed with an error. Check log file: ${LOG_FILE}"
    exit 1
fi
