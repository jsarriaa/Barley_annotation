#!/bin/bash
#
# Literal conversion of the Snakemake rule 'join_prothints'.
# This script concatenates, sorts, and merges hints using join_mult_hints.pl.

# --- Configuration: VARIABLES from the Snakemake Rule ---
# 1. Genome identifier
GENOME_ID="GDB_136" # Corresponds to {genome}

# 2. Input File(s)
# Note: Using the single active input from the rule:
INPUT_GFF_FILE="miniprot/${GENOME_ID}_uniref_plants_c50.miniprot_scored.hints.gff" # {input.gff}
# The commented out input is provided here for reference, in case it is needed later:
# INPUT_GFF_HC_FILE="miniprothints/${GENOME_ID}_uniref_tax38820.hc.hints.gff" # {input.gff_hc}

# 3. Output File
OUTPUT_GFF_FILE="miniprot/miniprot.hints.gff" # {output.gff}

# 4. Executable
# This tool is part of the AUGUSTUS suite, typically.
HINTS_JOINER_BIN="Augustus/scripts/join_mult_hints.pl"

# 5. Log File
LOG_FILE="logs/${GENOME_ID}.join_prothints.log"

# --- Setup ---
mkdir -p logs genome

echo "--- Starting join_prothints (Sorting and Merging) ---" | tee "${LOG_FILE}"
echo "Start time: $(date)" | tee -a "${LOG_FILE}"
echo "Input GFF: ${INPUT_GFF_FILE}" | tee -a "${LOG_FILE}"
echo "Output GFF: ${OUTPUT_GFF_FILE}" | tee -a "${LOG_FILE}"
echo "Threads: 1 (as specified in rule)" | tee -a "${LOG_FILE}"

# Check for required input files
if [ ! -f "${INPUT_GFF_FILE}" ]; then
    echo "ERROR: Soft hints input GFF not found at ${INPUT_GFF_FILE}" | tee -a "${LOG_FILE}"
    exit 1
fi

# Check for required executable (Tilde expansion is left to the shell)
if ! command -v "${HINTS_JOINER_BIN/~/}" &> /dev/null && [ ! -f "${HINTS_JOINER_BIN/~/}" ]; then
    echo "WARNING: Hints joiner script ${HINTS_JOINER_BIN} not found. Ensure path is correct." | tee -a "${LOG_FILE}"
fi

# --- SHELL COMMAND (LITERAL CONVERSION with complex piping) ---
# The entire pipeline is wrapped in a subshell to redirect all stderr/stdout to the log file.

(
    cat "${INPUT_GFF_FILE}" |
    sort -n -k 4,4 |
    sort -s -n -k 5,5 |
    sort -s -k 3,3 |
    sort -s -k 1,1 |
    "${HINTS_JOINER_BIN}" \
    > "${OUTPUT_GFF_FILE}"
) 2>&1 | tee -a "${LOG_FILE}"

JOINER_EXIT_CODE=$?

echo "" | tee -a "${LOG_FILE}"
echo "End time: $(date)" | tee -a "${LOG_FILE}"

if [ ${JOINER_EXIT_CODE} -eq 0 ]; then
    echo "join_prothints completed successfully." | tee -a "${LOG_FILE}"
else
    echo "ERROR: join_prothints failed with exit code ${JOINER_EXIT_CODE}." | tee -a "${LOG_FILE}"
fi

exit ${JOINER_EXIT_CODE}
