#!/bin/bash
#
# Literal conversion of the Snakemake rule 'miniprothints'.

# --- Configuration: VARIABLES from the Snakemake Rule ---
# 1. Genome identifier
GENOME_ID="GDB_136" # Corresponds to {genome}

# 2. Input File
INPUT_GFF_FILE="miniprot/${GENOME_ID}.uniref_plants_c50.miniprot_scored.gff" # {input.gff}

# 3. Executable and Working Directory (params.out)
HINTS_BIN="miniprothint/miniprothint.py"
WORKDIR="miniprothints" # {params.out}

# 4. Output Files (These are created inside the WORKDIR)
OUTPUT_GTF_FILE="${WORKDIR}/miniprot.gtf" # {output.out}
OUTPUT_HC_GFF_FILE="${WORKDIR}/hc.gff"     # {output.hc}

# 5. Log File
LOG_FILE="logs/${GENOME_ID}.tax38820_c50.miniprothints.log"

# --- Setup ---
mkdir -p logs genome "${WORKDIR}"

# Find miniprothint.py executable
if [ ! -f "${HINTS_BIN/~/}" ]; then
    echo "WARNING: ${HINTS_BIN} not found. Proceeding, but execution may fail if path is incorrect."
    # Note: We don't try to find it in PATH since the rule specifies a literal path.
fi

echo "--- Starting Miniprothints ---" | tee "${LOG_FILE}"
echo "Start time: $(date)" | tee -a "${LOG_FILE}"
echo "Input GFF: ${INPUT_GFF_FILE}" | tee -a "${LOG_FILE}"
echo "Working Directory: ${WORKDIR}" | tee -a "${LOG_FILE}"
echo "Output GTF: ${OUTPUT_GTF_FILE}" | tee -a "${LOG_FILE}"
echo "Threads: 1 (as specified in rule)" | tee -a "${LOG_FILE}"

# Check for required input file
if [ ! -f "${INPUT_GFF_FILE}" ]; then
    echo "ERROR: Input GFF file not found at ${INPUT_GFF_FILE}" | tee -a "${LOG_FILE}"
    exit 1
fi

# --- SHELL COMMAND (LITERAL CONVERSION) ---
# The command uses the python script with the GFF input file and the working directory.

(
    # Miniprothint command:
    "${HINTS_BIN}" \
        --workdir "${WORKDIR}" \
        "${INPUT_GFF_FILE}" \
        --ignoreCoverage

) 2>&1 | tee -a "${LOG_FILE}"

HINTS_EXIT_CODE=$?

echo "" | tee -a "${LOG_FILE}"
echo "End time: $(date)" | tee -a "${LOG_FILE}"

if [ ${HINTS_EXIT_CODE} -eq 0 ]; then
    echo "Miniprothints completed successfully." | tee -a "${LOG_FILE}"
else
    echo "ERROR: Miniprothints failed with exit code ${HINTS_EXIT_CODE}." | tee -a "${LOG_FILE}"
fi

exit ${HINTS_EXIT_CODE}
