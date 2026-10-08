#!/bin/bash
#
# Literal conversion of the Snakemake rule 'sortBambyreads'.
# Executes samtools sort to sort a BAM file by read name.

# --- Configuration: VARIABLES from the Snakemake Rule ---
# 1. Genome identifier
GENOME_ID="GDB_136" # Corresponds to {genome}

# 2. Input File
INPUT_BAM_FILE="STAR/alignments/allsamples.bam" # {genome}/allsamples.bam

# 3. Output File
OUTPUT_BAM_FILE="STAR/alignments/${GENOME_ID}_allsamples.s.bam" # {genome}/allsamples.s.bam

# 4. Resources
THREADS=32 # Corresponds to threads: 4 in the rule
# Note: The rule specifies -m 2G, but resources.MB is 16000 (16GB). 
# We'll stick to the shell command's explicit memory setting of 2G per thread.

# 5. Executable
SAMTOOLS_BIN=$(command -v samtools)

# 6. Log File
LOG_FILE="logs/${GENOME_ID}.sortBambyreads.log"

# --- Setup ---
mkdir -p logs "genome/${GENOME_ID}"

# Check for executable
if [ -z "${SAMTOOLS_BIN}" ]; then
    echo "ERROR: 'samtools' executable not found in PATH. Please ensure it is installed and accessible." | tee "${LOG_FILE}"
    exit 1
fi

echo "--- Starting samtools sort (by read name) ---" | tee "${LOG_FILE}"
echo "Start time: $(date)" | tee -a "${LOG_FILE}"
echo "Input BAM: ${INPUT_BAM_FILE}" | tee -a "${LOG_FILE}"
echo "Output BAM: ${OUTPUT_BAM_FILE}" | tee -a "${LOG_FILE}"
echo "Threads: ${THREADS}" | tee -a "${LOG_FILE}"
echo "Command executed: samtools sort -@ ${THREADS} -n -m 2G -o ${OUTPUT_BAM_FILE} ${INPUT_BAM_FILE}" | tee -a "${LOG_FILE}"

# Check for required input file
if [ ! -f "${INPUT_BAM_FILE}" ]; then
    echo "ERROR: Input BAM file not found at ${INPUT_BAM_FILE}" | tee -a "${LOG_FILE}"
    exit 1
fi

# --- SHELL COMMAND (LITERAL CONVERSION) ---
# The explicit memory (-m 2G) is included as it was in the Snakemake rule.

(
    "${SAMTOOLS_BIN}" sort \
        -@ "${THREADS}" \
        -n \
        -m 2G \
        -o "${OUTPUT_BAM_FILE}" \
        "${INPUT_BAM_FILE}"

) 2>&1 | tee -a "${LOG_FILE}"

SAMTOOLS_EXIT_CODE=$?

echo "" | tee -a "${LOG_FILE}"
echo "End time: $(date)" | tee -a "${LOG_FILE}"

if [ ${SAMTOOLS_EXIT_CODE} -eq 0 ]; then
    echo "samtools sort completed successfully." | tee -a "${LOG_FILE}"
else
    echo "ERROR: samtools sort failed with exit code ${SAMTOOLS_EXIT_CODE}." | tee -a "${LOG_FILE}"
fi

exit ${SAMTOOLS_EXIT_CODE}
