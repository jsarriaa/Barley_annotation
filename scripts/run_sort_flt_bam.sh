#!/bin/bash
#
# Literal conversion of the Snakemake rule 'sort_flt_BAM'.
# Executes the 'samtools sort' command on a filtered BAM file.

# --- Configuration: VARIABLES from the Snakemake Rule ---
# 1. Genome identifier
GENOME_ID="GDB_136" # Corresponds to {genome}

# 2. Input File (The filtered BAM: {genome}/allsamples.flt.bam)
INPUT_BAM_FILE="STAR/alignments/${GENOME_ID}_allsamples.flt.bam" 

# 3. Output File (The sorted filtered BAM: {genome}/allsamples.flt.s.bam)
OUTPUT_BAM_FILE="STAR/alignments/${GENOME_ID}_allsamples.flt.s.bam" 

# 4. Resources
THREADS=8 # Default is 4 but im adding more

# 5. Executable Path
SAMTOOLS_BIN=$(command -v samtools)

# 6. Log File
LOG_FILE="logs/${GENOME_ID}.sort_flt_bam.log"

# --- Setup ---
mkdir -p logs "genome/STAR"

# Check for executable
if [ -z "${SAMTOOLS_BIN}" ]; then
    echo "ERROR: 'samtools' executable not found in PATH." | tee "${LOG_FILE}"
    exit 1
fi

echo "--- Starting sort_flt_BAM ---" | tee "${LOG_FILE}"
echo "Message: Sorting BAM" | tee -a "${LOG_FILE}"
echo "Start time: $(date)" | tee -a "${LOG_FILE}"
echo "Input BAM: ${INPUT_BAM_FILE}" | tee -a "${LOG_FILE}"
echo "Output BAM: ${OUTPUT_BAM_FILE}" | tee -a "${LOG_FILE}"
echo "Threads: ${THREADS}" | tee -a "${LOG_FILE}"
echo "Memory per thread (-m): 2G" | tee -a "${LOG_FILE}"
echo "Command: ${SAMTOOLS_BIN} sort -@ ${THREADS} -m 2G -o ${OUTPUT_BAM_FILE} ${INPUT_BAM_FILE}" | tee -a "${LOG_FILE}"

# Check for required input file
if [ ! -f "${INPUT_BAM_FILE}" ]; then
    echo "ERROR: Input BAM file not found at ${INPUT_BAM_FILE}" | tee -a "${LOG_FILE}"
    exit 1
fi

# =======================================================
# --- SHELL COMMAND (LITERAL CONVERSION) ---
# samtools sort -@ {resources.threads} -m 2G -o {output.bam} {input.bam}
# =======================================================
(
    "${SAMTOOLS_BIN}" sort \
        -@ "${THREADS}" \
        -m 2G \
        -o "${OUTPUT_BAM_FILE}" \
        "${INPUT_BAM_FILE}"

) 2>&1 | tee -a "${LOG_FILE}"

SORT_EXIT_CODE=$?

echo "" | tee -a "${LOG_FILE}"
echo "End time: $(date)" | tee -a "${LOG_FILE}"

if [ ${SORT_EXIT_CODE} -eq 0 ]; then
    echo "sort_flt_BAM completed successfully." | tee -a "${LOG_FILE}"
else
    echo "ERROR: sort_flt_BAM failed with exit code ${SORT_EXIT_CODE}." | tee -a "${LOG_FILE}"
fi

exit ${SORT_EXIT_CODE}
