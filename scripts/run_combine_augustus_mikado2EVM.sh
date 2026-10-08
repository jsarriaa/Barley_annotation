#!/bin/bash
# run_combine_augustus_mikado2EVM.sh
# Combines all ab initio (AUGUSTUS and Mikado) gene predictions into a single GFF file for EVM input.

# --- Usage and Setup ---

GENOTYPE="GDB_136"
LOGS_DIR="logs"
RUN="RUN1"

# Input files (The four GFF files to be concatenated)
INPUT_GFF1="${GENOTYPE}/evm.abinitio.gff"             # Unfiltered AUGUSTUS (Source: AUGUSTUS)
INPUT_GFF2="${GENOTYPE}/evm.abinitio.supported.gff"   # Supported AUGUSTUS (Source: AUGSUPP)
INPUT_GFF3="mikado/${GENOTYPE}.mikado_refined_prediction.${RUN}.loci.gff3" # Mikado predictions
INPUT_GFF4="${GENOTYPE}/evm.abinitio.tsebra.gff"      # TSEBRA filtered output

# Output file
OUTPUT_GFF="${GENOTYPE}/evm.abinitio_gene_predictions.gff"

# Log file for this specific step
CURRENT_LOG="${LOGS_DIR}/${GENOTYPE}.combine_augustus_mikado2EVM.log"

# --- Pre-run Checks ---

# Ensure all input files exist
for file in "$INPUT_GFF1" "$INPUT_GFF2" "$INPUT_GFF3" "$INPUT_GFF4"; do
    if [ ! -f "$file" ]; then
        echo "Error: Input file not found: $file." >&2
        exit 1
    fi
done

# Ensure log directory exists
mkdir -p "$LOGS_DIR"

echo "--- Starting Ab Initio GFF Combination for Genotype: ${GENOTYPE} ---"
echo "Log: ${CURRENT_LOG}"

# Redirect all subsequent script output (stdout and stderr) to the main log file
exec &> "$CURRENT_LOG"

# --- Core Execution Step ---

echo "1. Concatenating all four GFF files..."
echo "Files being combined: GFF1, GFF2, GFF3, GFF4"

# Use 'cat' to merge the files in the specified order
cat "$INPUT_GFF1" \
    "$INPUT_GFF2" \
    "$INPUT_GFF3" \
    "$INPUT_GFF4" \
    > "$OUTPUT_GFF"

EXIT_CODE=$?

# --- Final Report ---

echo -e "\n--- Pipeline Summary ---"
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "GFF Combination: SUCCESS"
    echo "Combined ab initio GFF saved to: $OUTPUT_GFF"
    exit 0
else
    echo "ERROR: Combination failed (Exit Code $EXIT_CODE). Check log for details." >&2
    exit 1
fi
