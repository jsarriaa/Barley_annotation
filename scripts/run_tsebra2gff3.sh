#!/bin/bash
# run_tsebra2gff3.sh
# Converts the intermediate TSEBRA output file into a standard GFF3 file using gffread.

# --- Usage and Setup ---

GENOTYPE="GDB_136"
LOGS_DIR="logs"

# Input file (Intermediate TSEBRA output)
INPUT_GFF="${GENOTYPE}/augustus.hints.all_combined.gff"

# Output file (Final GFF3 format)
OUTPUT_GFF3="${GENOTYPE}/augustus.hints.all_combined.tsebra.gff3"

# Log file for this specific step
CURRENT_LOG="${LOGS_DIR}/${GENOTYPE}.augustus.tsebra2gff3.log"

# --- Pre-run Checks ---

if [ ! -f "$INPUT_GFF" ]; then
    echo "Error: Input GFF file not found at $INPUT_GFF." >&2
    exit 1
fi
# Note: gffread is assumed to be in the system PATH.

# Ensure log directory exists
mkdir -p "$LOGS_DIR"

echo "--- Starting TSEBRA Output to GFF3 Conversion for Genotype: ${GENOTYPE} ---"
echo "Log: ${CURRENT_LOG}"

# Redirect all subsequent script output (stdout and stderr) to the main log file
exec &> "$CURRENT_LOG"

# --- Core Execution Step ---

echo "1. Running gffread to convert GFF/GTF to GFF3..."
echo "Note: Using the -F flag to ensure parent gene features are created."

# Command: gffread <input> -F -o <output>
# The -F flag forces the creation of parent gene features, ensuring GFF3 hierarchy is correct.
gffread "$INPUT_GFF" \
    -F \
    -o "$OUTPUT_GFF3"

EXIT_CODE=$?

# --- Final Report ---

echo -e "\n--- Pipeline Summary ---"
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "TSEBRA output to GFF3 conversion: SUCCESS"
    echo "Final GFF3 saved to: $OUTPUT_GFF3"
    exit 0
else
    echo "ERROR: gffread conversion failed (Exit Code $EXIT_CODE). Check log for details." >&2
    exit 1
fi
