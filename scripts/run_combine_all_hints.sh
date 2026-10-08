#!/bin/bash
#
# Literal conversion of the Snakemake rule 'combine_all_hints'.
# This script concatenates, sorts, and saves all available AUGUSTUS hint GFF files.

# --- Configuration: VARIABLES from the Snakemake Rule ---
# 1. Genome identifier
GENOME_ID="GDB_136" # Corresponds to {genome}

# 2. Output File (Final combined hints: {genome}/hints.all_combined.gff)
OUTPUT_HINTS_FILE="${GENOME_ID}/hints.all_combined.gff"

# 3. Log File
LOG_FILE="logs/${GENOME_ID}.combinehints.log"

# --- Files to check (Simulating the hints_combine_input function based on existence) ---
# NOTE: In a non-Snakemake pipeline, we check for file existence instead of config keys.
HINT_FILES=()

# The full paths for the possible inputs
FILE_REFPROT="miniprothints/GDB_136_uniref_tax38820.hc.hints.gff"
FILE_RNASEQ="STAR/alignments/hints.intron_extrinsic.gff"
FILE_ISOSEQ="hints/hints.isoseq.mm2.gff"
FILE_EDTA="hints/hints.EDTA.gff"

# --- Setup ---
mkdir -p logs "${GENOME_ID}"

# --- Dynamic Input Gathering (Simulating hints_combine_input) ---
echo "--- Starting combine_all_hints ---" | tee "${LOG_FILE}"
echo "Message: Combine all hints" | tee -a "${LOG_FILE}"
echo "Start time: $(date)" | tee -a "${LOG_FILE}"
echo "Output GFF: ${OUTPUT_HINTS_FILE}" | tee -a "${LOG_FILE}"

# Build the dynamic list based on file existence
if [ -f "${FILE_REFPROT}" ]; then
    HINT_FILES+=("${FILE_REFPROT}")
    echo "Included: Reference Protein hints (${FILE_REFPROT})" | tee -a "${LOG_FILE}"
fi
if [ -f "${FILE_RNASEQ}" ]; then
    HINT_FILES+=("${FILE_RNASEQ}")
    echo "Included: RNA-Seq Extrinsic hints (${FILE_RNASEQ})" | tee -a "${LOG_FILE}"
fi
if [ -f "${FILE_ISOSEQ}" ]; then
    HINT_FILES+=("${FILE_ISOSEQ}")
    echo "Included: IsoSeq hints (${FILE_ISOSEQ})" | tee -a "${LOG_FILE}"
fi
if [ -f "${FILE_EDTA}" ]; then
    HINT_FILES+=("${FILE_EDTA}")
    echo "Included: EDTA TE hints (${FILE_EDTA})" | tee -a "${LOG_FILE}"
fi

if [ ${#HINT_FILES[@]} -eq 0 ]; then
    echo "WARNING: No hint files found to combine. Creating an empty output file." | tee -a "${LOG_FILE}"
    touch "${OUTPUT_HINTS_FILE}"
    exit 0
fi

# The files joined by spaces for 'cat'
INPUT_LIST="${HINT_FILES[@]}"
echo "Total files to combine: ${#HINT_FILES[@]}" | tee -a "${LOG_FILE}"
echo "--- Execution ---" | tee -a "${LOG_FILE}"

# =======================================================
# --- SHELL COMMAND (LITERAL CONVERSION) ---
# cat {input.gffs} | sort (4x) > {output.hints}
# Note: The original Snakemake rule has redundant sorting steps; 
# the most common GFF sort order is implemented here: sort by seq ID, then position.
# The original sort order: start (n), end (s,n), seq id (s), then the output is written.
# =======================================================

echo "Command: cat ${INPUT_LIST} | sort -n -k4,4 | sort -s -n -k5,5 | sort -s -k1,1 > ${OUTPUT_HINTS_FILE}" | tee -a "${LOG_FILE}"

(
    # cat reads all files in the dynamic array
    cat "${HINT_FILES[@]}" \
    | sort -n -k4,4 \
    | sort -s -n -k5,5 \
    | sort -s -k1,1 \
    > "${OUTPUT_HINTS_FILE}"
) 2>&1 | tee -a "${LOG_FILE}"

COMBINE_EXIT_CODE=$?

echo "" | tee -a "${LOG_FILE}"
echo "End time: $(date)" | tee -a "${LOG_FILE}"

if [ ${COMBINE_EXIT_CODE} -eq 0 ]; then
    echo "All hints combined successfully. Final file: ${OUTPUT_HINTS_FILE}" | tee -a "${LOG_FILE}"
else
    echo "ERROR: combine_all_hints failed with exit code ${COMBINE_EXIT_CODE}." | tee -a "${LOG_FILE}"
fi

exit ${COMBINE_EXIT_CODE}
