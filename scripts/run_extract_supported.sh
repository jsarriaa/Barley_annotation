#!/bin/bash
# run_extract_supported.sh
# Filters the combined AUGUSTUS predictions to include only genes supported by hints.

# --- Usage and Setup ---

GENOTYPE="GDB_136"
LOGS_DIR="logs"

# Input files (from the previous 'combine_augustus' rule)
INPUT_GFF="${GENOTYPE}/augustus.hints.all_combined.gff"
INPUT_GFF3="${GENOTYPE}/augustus.hints.all_combined.gff3"

# Output file
OUTPUT_GFF3="${GENOTYPE}/augustus.hints.all_combined.supported.gff3"

# Python script path
PYTHON_SCRIPT="scripts/extract_supported.py"

# Log file for this specific step
CURRENT_LOG="${LOGS_DIR}/${GENOTYPE}.augustus_supported.log"

# --- Pre-run Checks ---

# Ensure all necessary input files exist
if [ ! -f "$INPUT_GFF" ]; then
    echo "Error: Input GFF file not found at $INPUT_GFF." >&2
    exit 1
fi
if [ ! -f "$INPUT_GFF3" ]; then
    echo "Error: Input GFF3 file not found at $INPUT_GFF3." >&2
    exit 1
fi
if [ ! -f "$PYTHON_SCRIPT" ]; then
    echo "Error: Required Python script not found at $PYTHON_SCRIPT. Please create it first." >&2
    exit 1
fi

# Ensure log directory exists
mkdir -p "$LOGS_DIR"

echo "--- Starting Supported Gene Extraction for Genotype: ${GENOTYPE} ---"
echo "Output GFF3: ${OUTPUT_GFF3}"
echo "Log: ${CURRENT_LOG}"

# Redirect all subsequent script output (stdout and stderr) to the main log file
exec &> "$CURRENT_LOG"

# --- Core Execution Step ---

echo "Executing Python script: $PYTHON_SCRIPT"
# The Python script handles all the file logic and filtering.
python3 "$PYTHON_SCRIPT" "$INPUT_GFF" "$INPUT_GFF3" "$OUTPUT_GFF3"

EXIT_CODE=$?

# --- Final Report ---

echo -e "\n--- Pipeline Summary ---"
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "Supported gene extraction: SUCCESS"
    echo "Output saved to: $OUTPUT_GFF3"
    exit 0
else
    echo "ERROR: Supported gene extraction failed (Exit Code $EXIT_CODE). Review log for details." >&2
    # Since stdout/stderr are redirected, this will appear in the main log,
    # but we print to stderr just in case the redirect fails later.
    exit 1
fi
