#!/bin/bash
#
# Literal conversion of the Snakemake rule 'wig2hints'.
# Executes the 'wig2hints.pl' script to convert WIG coverage to evidence hints (ep_hints.gff).

# --- Configuration: VARIABLES from the Snakemake Rule ---
# 1. Genome identifier
GENOME_ID="GDB_136" # Corresponds to {genome}

# 2. Input File (WIG: {genome}/allsamples.flt.s.wig)
INPUT_WIG_FILE="STAR/alignments/${GENOME_ID}_allsamples.flt.s_bam2wig/${GENOME_ID}_allsamples.flt.s.wig"

# 3. Output File (GFF hints: {genome}/ep_hints.gff)
OUTPUT_GFF_FILE="hints/ep_hints.gff"

# 4. Executable Path
WIG2HINTS_SCRIPT="Augustus/scripts/wig2hints.pl"

# 5. Log File
LOG_FILE="logs/${GENOME_ID}.wig2hints.log"

# --- Setup ---
mkdir -p logs "${GENOME_ID}" # Ensure the necessary directories exist
mkdir -p hints

# Check for required input file
if [ ! -f "${INPUT_WIG_FILE}" ]; then
    echo "ERROR: Input WIG file not found at ${INPUT_WIG_FILE}" | tee "${LOG_FILE}"
    exit 1
fi

echo "--- Starting wig2hints ---" | tee "${LOG_FILE}"
echo "Message: Running wig2hints" | tee -a "${LOG_FILE}"
echo "Start time: $(date)" | tee -a "${LOG_FILE}"
echo "Input WIG: ${INPUT_WIG_FILE}" | tee -a "${LOG_FILE}"
echo "Output GFF: ${OUTPUT_GFF_FILE}" | tee -a "${LOG_FILE}"
echo "Command: ${WIG2HINTS_SCRIPT} --margin=10 ... < ${INPUT_WIG_FILE} > ${OUTPUT_GFF_FILE}" | tee -a "${LOG_FILE}"


# =======================================================
# --- SHELL COMMAND (LITERAL CONVERSION) ---
# ~/tools/Augustus/scripts/wig2hints.pl [options] < {input.wig} > {output.ephints}
# =======================================================
(
    # Use 'eval' to handle the '~' expansion and pipe the WIG file via standard input ('<')
    eval "${WIG2HINTS_SCRIPT} \
        --margin=10 \
        --minthresh=2 \
        --minscore=4 \
        --prune=0.1 \
        --src=W \
        --type=ep \
        --radius=4.5 \
        --pri=4 \
        --strand=\".\" \
        < ${INPUT_WIG_FILE} \
        > ${OUTPUT_GFF_FILE}"

) 2>&1 | tee -a "${LOG_FILE}"

WIG2HINTS_EXIT_CODE=$?

echo "" | tee -a "${LOG_FILE}"
echo "End time: $(date)" | tee -a "${LOG_FILE}"

if [ ${WIG2HINTS_EXIT_CODE} -eq 0 ]; then
    echo "wig2hints completed successfully." | tee -a "${LOG_FILE}"
else
    echo "ERROR: wig2hints failed with exit code ${WIG2HINTS_EXIT_CODE}." | tee -a "${LOG_FILE}"
fi

exit ${WIG2HINTS_EXIT_CODE}
