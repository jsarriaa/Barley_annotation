#!/bin/bash
#
# Literal conversion of the Snakemake rule 'filterIntronsFindStrand'.

# --- Configuration: VARIABLES from the Snakemake Rule ---
# 1. Genome identifier
GENOME_ID="GDB_136" # Corresponds to {genome}

# 2. Input File 1 (GFF hints: {genome}/intron_hints.gff)
INPUT_GFF_FILE="STAR/alignments/intron_hints.gff"

# 3. Input File 2 (Genome FASTA: {genome}/{genome}.fa)
INPUT_FASTA_FILE="data/${GENOME_ID}.fa"

# 4. Output File (Filtered GFF: {genome}/intron_hints.flt.gff)
OUTPUT_FLT_FILE="STAR/alignments/intron_hints.flt.gff"

# 5. Executable Path
SCRIPT_PATH="GALBA/scripts/filterIntronsFindStrand.pl"

# 6. Parameters
SCORE_THRESHOLD=1 # Corresponds to --score 1

# 7. Log File (FIX: Must be defined)
LOG_FILE="logs/${GENOME_ID}.filterIntronsFindStrand.log"

# Temporary file definition (FIX: Use a guaranteed-writable location like /tmp)
MODIFIED_FASTA_FILE="/tmp/${GENOME_ID}_phg_temp.fa"
TEMP_LOG="logs/fasta_mod_${GENOME_ID}.log"

# --- Initial Checks ---
if [ ! -f "${INPUT_GFF_FILE}" ]; then
    echo "ERROR: Input GFF file not found at ${INPUT_GFF_FILE}" | tee "${LOG_FILE}"
    exit 1
fi

if [ ! -f "${INPUT_FASTA_FILE}" ]; then
    echo "ERROR: Input FASTA file not found at ${INPUT_FASTA_FILE}" | tee "${LOG_FILE}"
    exit 1
fi

echo "--- Starting filterIntronsFindStrand ---" | tee "${LOG_FILE}"
echo "Input GFF: ${INPUT_GFF_FILE}" | tee -a "${LOG_FILE}"
# ... (rest of initial logging) ...

# --- FASTA HEADER STANDARDIZATION ---
echo "--- Standardizing FASTA headers to match GFF ---" | tee -a "${LOG_FILE}"
echo "Creating temp FASTA file: ${MODIFIED_FASTA_FILE}" | tee -a "${LOG_FILE}"

# sed command to strip everything after the first space on header lines starting with '>'
sed '/^>/ s/\s.*//' "${INPUT_FASTA_FILE}" > "${MODIFIED_FASTA_FILE}" 2> "${TEMP_LOG}"

# Check the success of the FASTA modification
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to modify FASTA headers. Check ${TEMP_LOG}" | tee -a "${LOG_FILE}"
    rm -f "${MODIFIED_FASTA_FILE}" # Cleanup failure
    exit 1
fi

# =======================================================
# --- SHELL COMMAND (LITERAL CONVERSION) ---
# FIX: Use a clean single-line variable for eval
# =======================================================
COMMAND_LINE="${SCRIPT_PATH} ${MODIFIED_FASTA_FILE} ${INPUT_GFF_FILE} --score ${SCORE_THRESHOLD} > ${OUTPUT_FLT_FILE}"
echo "Command: ${COMMAND_LINE}" | tee -a "${LOG_FILE}"

(
    eval "${COMMAND_LINE}"

) 2>&1 | tee -a "${LOG_FILE}"

FILTER_EXIT_CODE=$?

# --- Final Cleanup and Reporting ---
echo "" | tee -a "${LOG_FILE}"
echo "End time: $(date)" | tee -a "${LOG_FILE}"

if [ ${FILTER_EXIT_CODE} -eq 0 ]; then
    echo "filterIntronsFindStrand completed successfully." | tee -a "${LOG_FILE}"
else
    echo "ERROR: filterIntronsFindStrand failed with exit code ${FILTER_EXIT_CODE}. Check log for details." | tee -a "${LOG_FILE}"
fi

# Clean up the temporary file
rm -f "${MODIFIED_FASTA_FILE}"

exit ${FILTER_EXIT_CODE}
