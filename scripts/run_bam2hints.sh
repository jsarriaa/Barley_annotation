#!/bin/bash
#
# Literal conversion of the Snakemake rule 'bam2hints'.
# Executes the 'bam2hints' tool to generate intron hints in GFF format.

# --- Configuration: VARIABLES from the Snakemake Rule ---
# 1. Genome identifier
GENOME_ID="GDB_136" # Corresponds to {genome}

# 2. Input File (The sorted filtered BAM: {genome}/allsamples.flt.s.bam)
INPUT_BAM_FILE="STAR/alignments/${GENOME_ID}_allsamples.flt.s.bam" 

# 3. Output File (The GFF hints file: {genome}/intron_hints.gff)
# Note: Assuming the GFF output path should be under a directory named after the genome.
OUTPUT_GFF_FILE="STAR/alignments/intron_hints.gff" 

# 4. Resources
THREADS=16 # Default 1 but im using more

# 5. Executable Path
# NOTE: bam2hints is part of the AUGUSTUS suite. Ensure it is in your PATH.
BAM2HINTS_BIN=$(command -v bam2hints)

# 6. Log File
LOG_FILE="logs/${GENOME_ID}.bam2hints.log"

# --- Setup ---
mkdir -p logs "genome/${GENOME_ID}" # Ensure the necessary directories exist

# Check for executable
if [ -z "${BAM2HINTS_BIN}" ]; then
    echo "ERROR: 'bam2hints' executable not found in PATH." | tee "${LOG_FILE}"
    exit 1
fi

echo "--- Starting bam2hints ---" | tee "${LOG_FILE}"
echo "Message: Running bam2hints" | tee -a "${LOG_FILE}"
echo "Start time: $(date)" | tee -a "${LOG_FILE}"
echo "Input BAM: ${INPUT_BAM_FILE}" | tee -a "${LOG_FILE}"
echo "Output GFF: ${OUTPUT_GFF_FILE}" | tee -a "${LOG_FILE}"
echo "Threads: ${THREADS}" | tee -a "${LOG_FILE}" # Note: bam2hints is often single-threaded
echo "Command: ${BAM2HINTS_BIN} --intronsonly --in=${INPUT_BAM_FILE} --out=${OUTPUT_GFF_FILE}" | tee -a "${LOG_FILE}"

# Check for required input file
if [ ! -f "${INPUT_BAM_FILE}" ]; then
    echo "ERROR: Input BAM file not found at ${INPUT_BAM_FILE}" | tee -a "${LOG_FILE}"
    exit 1
fi

# =======================================================
# --- SHELL COMMAND (LITERAL CONVERSION) ---
# bam2hints --intronsonly --in={input.bam} --out={output.gff}
# =======================================================
(
    "${BAM2HINTS_BIN}" \
        --intronsonly \
        --in="${INPUT_BAM_FILE}" \
        --out="${OUTPUT_GFF_FILE}"

) 2>&1 | tee -a "${LOG_FILE}"

BAM2HINTS_EXIT_CODE=$?

echo "" | tee -a "${LOG_FILE}"
echo "End time: $(date)" | tee -a "${LOG_FILE}"

if [ ${BAM2HINTS_EXIT_CODE} -eq 0 ]; then
    echo "bam2hints completed successfully." | tee -a "${LOG_FILE}"
else
    echo "ERROR: bam2hints failed with exit code ${BAM2HINTS_EXIT_CODE}." | tee -a "${LOG_FILE}"
fi

exit ${BAM2HINTS_EXIT_CODE}
