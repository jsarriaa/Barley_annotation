#!/bin/bash
#
# Literal conversion of the Snakemake rule 'merge_extrinsic_hints'.
# This script merges intron hints and exon part (ep) hints, sorts them,
# and passes them to join_mult_hints.pl to create a final combined GFF hints file.

# --- Configuration: VARIABLES from the Snakemake Rule ---
# 1. Genome identifier
GENOME_ID="GDB_136" # Corresponds to {genome}

# 2. Input File 1 (Intron hints: {genome}/intron_hints.flt.gff)
INPUT_INTRON_FILE="STAR/alignments/intron_hints.flt.gff"

# 3. Input File 2 (Exon part hints: {genome}/ep_hints.gff)
INPUT_EP_FILE="hints/ep_hints.gff"

# 4. Output File (Merged GFF: {genome}/hints.intron_extrinsic.gff)
OUTPUT_GFF_FILE="STAR/alignments/hints.intron_extrinsic.gff"

# 5. Executable Path (Assuming join_mult_hints.pl is in PATH)
JOIN_MULT_HINTS_BIN=$(command -v Augustus/scripts/join_mult_hints.pl)

# 6. Log File
LOG_FILE="logs/${GENOME_ID}.merge_extrinsic_hints.log"

# --- Setup ---
mkdir -p logs "${GENOME_ID}" # Ensure the necessary directories exist

# Check for required input files
if [ ! -f "${INPUT_INTRON_FILE}" ]; then
    echo "ERROR: Intron hints file not found at ${INPUT_INTRON_FILE}" | tee "${LOG_FILE}"
    exit 1
fi
if [ ! -f "${INPUT_EP_FILE}" ]; then
    echo "ERROR: EP hints file not found at ${INPUT_EP_FILE}" | tee "${LOG_FILE}"
    exit 1
fi
if [ -z "${JOIN_MULT_HINTS_BIN}" ]; then
    echo "WARNING: 'join_mult_hints.pl' executable not found in PATH. Command may fail." | tee "${LOG_FILE}"
fi

echo "--- Starting merge_extrinsic_hints ---" | tee "${LOG_FILE}"
echo "Message: merging intron and ep hints" | tee -a "${LOG_FILE}"
echo "Start time: $(date)" | tee -a "${LOG_FILE}"
echo "Input Intron GFF: ${INPUT_INTRON_FILE}" | tee -a "${LOG_FILE}"
echo "Input EP GFF: ${INPUT_EP_FILE}" | tee -a "${LOG_FILE}"
echo "Output GFF: ${OUTPUT_GFF_FILE}" | tee -a "${LOG_FILE}"
echo "Command: cat {input.intron} {input.ep} | sort -n -k 4,4 | sort -s -n -k 5,5 | sort -s -k 3,3 | sort -s -k 1,1 | join_mult_hints.pl > ${OUTPUT_GFF_FILE}" | tee -a "${LOG_FILE}"


# =======================================================
# --- SHELL COMMAND (LITERAL CONVERSION) ---
# cat {input.intron} {input.ep} | sort... | join_mult_hints.pl > {output.gff}
# =======================================================
(
    cat "${INPUT_INTRON_FILE}" "${INPUT_EP_FILE}" \
    | sort -n -k 4,4 \
    | sort -s -n -k 5,5 \
    | sort -s -k 3,3 \
    | sort -s -k 1,1 \
    | "${JOIN_MULT_HINTS_BIN}" > "${OUTPUT_GFF_FILE}"

) 2>&1 | tee -a "${LOG_FILE}"

MERGE_EXIT_CODE=$?

echo "" | tee -a "${LOG_FILE}"
echo "End time: $(date)" | tee -a "${LOG_FILE}"

if [ ${MERGE_EXIT_CODE} -eq 0 ]; then
    echo "merge_extrinsic_hints completed successfully." | tee -a "${LOG_FILE}"
else
    echo "ERROR: merge_extrinsic_hints failed with exit code ${MERGE_EXIT_CODE}." | tee -a "${LOG_FILE}"
fi

exit ${MERGE_EXIT_CODE}
