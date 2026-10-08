#!/bin/bash
#
# Literal conversion of the Snakemake rule 'filterbam'.
# Executes the 'filterBam' tool to clean up BAM alignments.

# --- Configuration: VARIABLES from the Snakemake Rule ---
# 1. Genome identifier
GENOME_ID="GDB_136" # Corresponds to {genome}

# 2. Input File
INPUT_BAM_FILE="STAR/alignments/${GENOME_ID}_allsamples.s.bam" # {genome}/allsamples.s.bam

# 3. Output File
OUTPUT_BAM_FILE="STAR/alignments/${GENOME_ID}_allsamples.flt.bam" # {genome}/allsamples.flt.bam

# 4. Executable
# NOTE: 'filterBam' is often not in the PATH. If this script fails,
# replace the line below with the absolute path to your filterBam executable.
FILTERBAM_BIN=$(command -v filterBam)

# 5. Log File
LOG_FILE="logs/${GENOME_ID}.filterBAM.log"

# --- Setup ---
mkdir -p logs

# Check for executable
if [ -z "${FILTERBAM_BIN}" ]; then
    echo "ERROR: 'filterBam' executable not found in PATH." | tee "${LOG_FILE}"
    echo "Please find its absolute path (e.g., in a BRAKER/AUGUSTUS install) and update the FILTERBAM_BIN variable." | tee -a "${LOG_FILE}"
    exit 1
fi

echo "--- Starting filterBam ---" | tee "${LOG_FILE}"
echo "Start time: $(date)" | tee -a "${LOG_FILE}"
echo "Input BAM: ${INPUT_BAM_FILE}" | tee -a "${LOG_FILE}"
echo "Output BAM: ${OUTPUT_BAM_FILE}" | tee -a "${LOG_FILE}"
echo "Threads: 1 (as specified in rule)" | tee -a "${LOG_FILE}"
echo "Command executed: ${FILTERBAM_BIN} --uniq --paired --pairwiseAlignments --in ${INPUT_BAM_FILE} --out ${OUTPUT_BAM_FILE}" | tee -a "${LOG_FILE}"

# Check for required input file
if [ ! -f "${INPUT_BAM_FILE}" ]; then
    echo "ERROR: Input BAM file not found at ${INPUT_BAM_FILE}" | tee -a "${LOG_FILE}"
    exit 1
fi

# --- SHELL COMMAND (LITERAL CONVERSION) ---
(
    "${FILTERBAM_BIN}" \
        --uniq \
        --paired \
        --pairwiseAlignments \
        --in "${INPUT_BAM_FILE}" \
        --out "${OUTPUT_BAM_FILE}"

) 2>&1 | tee -a "${LOG_FILE}"

FILTERBAM_EXIT_CODE=$?

echo "" | tee -a "${LOG_FILE}"
echo "End time: $(date)" | tee -a "${LOG_FILE}"

if [ ${FILTERBAM_EXIT_CODE} -eq 0 ]; then
    echo "filterBam completed successfully." | tee -a "${LOG_FILE}"
else
    echo "ERROR: filterBam failed with exit code ${FILTERBAM_EXIT_CODE}." | tee -a "${LOG_FILE}"
fi

exit ${FILTERBAM_EXIT_CODE}
