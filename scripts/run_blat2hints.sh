#!/bin/bash
#
# Literal conversion of the Snakemake rule 'blat2hints'.
# This script finds and concatenates all IsoSeq PSL mapping files, sorts them,
# and converts them into AUGUSTUS hints using blat2hints.pl.

# --- Configuration: VARIABLES from the Snakemake Rule ---
# 1. Genome identifier
GENOME_ID="GDB_136" # Corresponds to {genome}

# 2. Input Directory (Source for PSL files)
INPUT_PSL_DIR="data/"

# 3. Output File (GFF hints: {genome}/hints.isoseq.mm2.gff)
OUTPUT_GFF_FILE="hints/hints.isoseq.mm2.gff"

# 4. Executable Path
# NOTE: blat2hints.pl is part of the AUGUSTUS.
BLAT2HINTS_BIN=$(command -v Augustus/scripts/blat2hints.pl)

# 5. Parameters for blat2hints.pl
SOURCE="PB"
NOMULT="--nomult"
EP_CUTOFF=20
IN="/dev/stdin" # Script reads from standard input
OUT="${OUTPUT_GFF_FILE}"

# 6. Log File
LOG_FILE="logs/${GENOME_ID}.blat2hints.log"

# --- Setup ---
mkdir -p logs "${GENOME_ID}" # Ensure the necessary directories exist

# Check for executable
if [ -z "${BLAT2HINTS_BIN}" ]; then
    echo "ERROR: 'blat2hints.pl' executable not found in PATH." | tee "${LOG_FILE}"
    exit 1
fi

echo "--- Starting blat2hints ---" | tee "${LOG_FILE}"
echo "Message: Make hints from isoseq" | tee -a "${LOG_FILE}"
echo "Start time: $(date)" | tee -a "${LOG_FILE}"
echo "Input Directory: ${INPUT_PSL_DIR}/*.psl" | tee -a "${LOG_FILE}"
echo "Output GFF: ${OUTPUT_GFF_FILE}" | tee -a "${LOG_FILE}"
echo "blat2hints options: --source=${SOURCE} ${NOMULT} --ep_cutoff=${EP_CUTOFF}" | tee -a "${LOG_FILE}"
echo "Full Command (Pipelined): find ${INPUT_PSL_DIR} -name \"*.psl\" -exec cat {} \; | sort -n -k 16,16 | sort -s -k 14,14 | ${BLAT2HINTS_BIN} --source=... > ${OUTPUT_GFF_FILE}" | tee -a "${LOG_FILE}"

# Check for required input files (at least the directory)
if [ ! -d "${INPUT_PSL_DIR}" ]; then
    echo "ERROR: Input directory for PSL files not found: ${INPUT_PSL_DIR}" | tee -a "${LOG_FILE}"
    exit 1
fi

# =======================================================
# --- SHELL COMMAND (LITERAL CONVERSION) ---
# find ... | sort ... | sort ... | blat2hints.pl ... > {output.gff}
# =======================================================
(
    # Find all .psl files and concatenate them
    find "${INPUT_PSL_DIR}" -name "*.psl" -exec cat {} \; \
    | sort -n -k 16,16 \
    | sort -s -k 14,14 \
    | "${BLAT2HINTS_BIN}" \
        --source="${SOURCE}" \
        "${NOMULT}" \
        --ep_cutoff="${EP_CUTOFF}" \
        --in="${IN}" \
        --out="${OUTPUT_GFF_FILE}"

) 2>&1 | tee -a "${LOG_FILE}"

BLAT2HINTS_EXIT_CODE=$?

echo "" | tee -a "${LOG_FILE}"
echo "End time: $(date)" | tee -a "${LOG_FILE}"

if [ ${BLAT2HINTS_EXIT_CODE} -eq 0 ]; then
    echo "blat2hints completed successfully. Hints saved to ${OUTPUT_GFF_FILE}" | tee -a "${LOG_FILE}"
else
    echo "ERROR: blat2hints failed with exit code ${BLAT2HINTS_EXIT_CODE}." | tee -a "${LOG_FILE}"
fi

exit ${BLAT2HINTS_EXIT_CODE}
