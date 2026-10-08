#!/bin/bash
# Description: Concatenates all individual EVM-formatted ab initio gene prediction GFF files 
# into a single GFF file for use as the ab initio input source for EVidenceModeler.

# --- USER-DEFINED VARIABLES ---
GENOTYPE="GDB_136"
RUN="RUN1"

# --- FILE PATHS ---
# Input GFFs (from previous conversion steps)
INPUT_GFFS=(
    "${GENOTYPE}/evm.abinitio.gff"             # Raw Augustus
    "${GENOTYPE}/evm.abinitio.supported.gff"   # Augustus Supported
#"transcripts/${GENOTYPE}_mikado_transcripts.loci.gff3" # Mikado Loci (assuming already EVM compatible or simple GFF3)
    "mikado/${GENOTYPE}.mikado_refined_prediction.${RUN}.loci.gff3"
    "${GENOTYPE}/evm.abinitio.tsebra.gff"      # TSEBRA filtered
    "${GENOTYPE}/evm.abinitio.helixer.gff"      # Helixer
)
# Output: Final combined ab initio GFF file for EVM
OUTPUT_GFF="${GENOTYPE}/evm.abinitio_gene_predictions.gff"

LOG_FILE="logs/${GENOTYPE}.combine_augustus_mikado2EVM.log"

# --- SETUP AND INPUT CHECK ---
mkdir -p logs

# Check if all required input files exist
MISSING_FILES=0
for FILE in "${INPUT_GFFS[@]}"; do
    if [ ! -f "$FILE" ]; then
        echo "ERROR: Missing required input file: $FILE" | tee -a "$LOG_FILE"
        MISSING_FILES=1
    fi
done

if [ "$MISSING_FILES" -eq 1 ]; then
    echo "--- ABORTING: One or more input GFF files were not found. ---" | tee -a "$LOG_FILE"
    exit 1
fi

echo "--- Starting Combination of Ab Initio GFFs for EVM for ${GENOTYPE} ---" | tee "$LOG_FILE"
echo "Combined output will be saved to: $OUTPUT_GFF" | tee -a "$LOG_FILE"

# --- CORE EXECUTION ---

# Use 'cat' to concatenate all files listed in the array to the single output file.
cat "${INPUT_GFFS[@]}" > "${OUTPUT_GFF}" 2>> "$LOG_FILE"

EXIT_CODE=$?

# --- FINAL REPORT ---
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "--- SUCCESS: All ab initio GFFs combined successfully ---" | tee -a "$LOG_FILE"
else
    # Cat failures are usually file permission or disk issues.
    echo "--- ERROR: GFF combination failed (Exit Code: $EXIT_CODE). ---" | tee -a "$LOG_FILE"
    exit 1
fi

exit $EXIT_CODE
