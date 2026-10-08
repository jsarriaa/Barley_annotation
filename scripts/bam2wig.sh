#!/bin/bash
#
# Literal conversion of the Snakemake rule 'bam2wig'.
# Executes the 'bam2wig' tool to convert a sorted BAM file to a WIG file.

# --- Configuration: VARIABLES from the Snakemake Rule ---
# 1. Genome identifier
GENOME_ID="GDB_136" # Corresponds to {genome}

# 2. Input File (BAM: {genome}/allsamples.flt.s.bam)
INPUT_BAM_FILE="STAR/alignments/${GENOME_ID}_allsamples.flt.s.bam"

# 3. Output File (WIG: {genome}/allsamples.flt.s.wig)
OUTPUT_WIG_FILE="STAR/alignments/${GENOME_ID}_allsamples.flt.s.wig"

# 4. Executable Path
BAM2WIG="scripts/bam2wig"

# 5. Log File
LOG_FILE="logs/${GENOME_ID}.bam2wig.log"

# --- Setup ---
mkdir -p logs "${GENOME_ID}" # Ensure the necessary directories exist

echo "--- Starting bam2wig ---" | tee "${LOG_FILE}"
echo "Message: Running bam2wig" | tee -a "${LOG_FILE}"
echo "Start time: $(date)" | tee -a "${LOG_FILE}"
echo "Input BAM: ${INPUT_BAM_FILE}" | tee -a "${LOG_FILE}"
echo "Output WIG: ${OUTPUT_WIG_FILE}" | tee -a "${LOG_FILE}"
echo "Command: perl ${BAM2WIG} ${INPUT_BAM_FILE} > ${OUTPUT_WIG_FILE}" | tee -a "${LOG_FILE}"

# Check for required input file
if [ ! -f "${INPUT_BAM_FILE}" ]; then
    echo "ERROR: Input BAM file not found at ${INPUT_BAM_FILE}" | tee -a "${LOG_FILE}"
    exit 1
fi

# =======================================================
# --- SHELL COMMAND (LITERAL CONVERSION) ---
# bam2wig {input.bam} > {output.wig}
# =======================================================
(
    "perl" "${BAM2WIG}" "${INPUT_BAM_FILE}" > "${OUTPUT_WIG_FILE}"

) 2>&1 | tee -a "${LOG_FILE}"

BAM2WIG_EXIT_CODE=$?

echo "" | tee -a "${LOG_FILE}"
echo "End time: $(date)" | tee -a "${LOG_FILE}"

if [ ${BAM2WIG_EXIT_CODE} -eq 0 ]; then
    echo "bam2wig completed successfully." | tee -a "${LOG_FILE}"
else
    echo "ERROR: bam2wig failed with exit code ${BAM2WIG_EXIT_CODE}." | tee -a "${LOG_FILE}"
fi

exit ${BAM2WIG_EXIT_CODE}
