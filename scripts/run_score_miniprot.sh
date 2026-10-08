#!/bin/bash
#

# --- Configuration: VARIABLES from the Snakemake Rule ---
# 1. Genome identifier
GENOME_ID="GDB_136"

# 2. Input File
INPUT_ALN_FILE="miniprot/${GENOME_ID}.uniref_tax38820_id0.5.miniprot.aln"
GDB_136.uniref_tax38820_id0.5.miniprot.aln

# 3. Output File
OUTPUT_GFF_FILE="miniprot/${GENOME_ID}.uniref_plants_c50.miniprot_scored.gff" # {genome}/{genome}.uniref_plants_c50.miniprot_scored.gff

# 4. Log File
LOG_FILE="logs/${GENOME_ID}.uniref_plants_c50.miniprot_boundary_scorer.log"

# miniprot scorer bin path
SCORER_BIN="miniprot-boundary-scorer/miniprot_boundary_scorer"
BLOSUM_FILE="miniprot-boundary-scorer/blosum62.csv"

# --- Setup ---
mkdir -p logs genome

echo "--- Starting Miniprot Boundary Scorer ---" | tee "${LOG_FILE}"
echo "Start time: $(date)" | tee -a "${LOG_FILE}"
echo "Input ALN: ${INPUT_ALN_FILE}" | tee -a "${LOG_FILE}"
echo "Output GFF: ${OUTPUT_GFF_FILE}" | tee -a "${LOG_FILE}"
echo "Threads: 1 (as specified in rule)" | tee -a "${LOG_FILE}"
echo "Command executed: ${SCORER_BIN} -s ${BLOSUM_FILE} -o ${OUTPUT_GFF_FILE} < ${INPUT_ALN_FILE}" | tee -a "${LOG_FILE}"

# Check for required input file
if [ ! -f "${INPUT_ALN_FILE}" ]; then
    echo "ERROR: Input ALN file not found at ${INPUT_ALN_FILE}" | tee -a "${LOG_FILE}"
    exit 1
fi

# --- SHELL COMMAND (LITERAL CONVERSION) ---
# The command uses input redirection ('<') as specified in the rule.
# The entire command is run in a subshell to capture all stdout/stderr to the log.

(
    # Miniprot Scorer command:
    "${SCORER_BIN}" \
        -s "${BLOSUM_FILE}" \
        -o "${OUTPUT_GFF_FILE}" \
        < "${INPUT_ALN_FILE}"

) 2>&1 | tee -a "${LOG_FILE}"

SCORER_EXIT_CODE=$?

echo "" | tee -a "${LOG_FILE}"
echo "End time: $(date)" | tee -a "${LOG_FILE}"

if [ ${SCORER_EXIT_CODE} -eq 0 ]; then
    echo "Miniprot boundary scoring completed successfully." | tee -a "${LOG_FILE}"
else
    echo "ERROR: Miniprot boundary scoring failed with exit code ${SCORER_EXIT_CODE}." | tee -a "${LOG_FILE}"
fi

exit ${SCORER_EXIT_CODE}
