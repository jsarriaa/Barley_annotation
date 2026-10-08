#!/bin/bash
# run_tsebra.sh
# Executes the TSEBRA script to select the best AUGUSTUS transcripts based on hints and a config file.
# FIX: Includes AWK step to fix the score column in the hints file.

# --- Usage and Setup ---

GENOTYPE="GDB_136"
LOGS_DIR="logs"

# Input files
INPUT_GFF="${GENOTYPE}/augustus.hints.all_combined.gff"
INPUT_HINTS="${GENOTYPE}/hints.all_combined.gff" # This file needs score column fixing

# Output file
OUTPUT_GFF="${GENOTYPE}/augustus.hints.all_combined.tsebra.gff"

# Parameters
CONFIG_FILE="pananno/pananno.cfg"
EXPANDED_TSEBRA_TOOL="/scratch/software-phgv2/miniconda3/envs/pananno/bin/tsebra.py"

# Temporary file for the fixed hints
TEMP_HINTS="${GENOTYPE}/hints.all_combined.fixed.gff"

# Log file for this specific step
CURRENT_LOG="${LOGS_DIR}/${GENOTYPE}.augustus.tsebra.log"

# --- Pre-run Checks ---

# 1. Expand paths and check tool existence
if [ ! -x "$EXPANDED_TSEBRA_TOOL" ]; then
    echo "Error: TSEBRA tool not found or is not executable at $EXPANDED_TSEBRA_TOOL." >&2
    exit 1
fi

# 2. Check input/config file existence
if [ ! -f "$INPUT_GFF" ] || [ ! -f "$INPUT_HINTS" ] || [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: One or more input/config files are missing." >&2
    echo "Checked files: $INPUT_GFF, $INPUT_HINTS, $CONFIG_FILE" >&2
    exit 1
fi

# Ensure log directory exists
mkdir -p "$LOGS_DIR"

echo "--- Starting TSEBRA Transcript Selection for Genotype: ${GENOTYPE} ---"
echo "Log: ${CURRENT_LOG}"

# Redirect all subsequent script output (stdout and stderr) to the main log file
exec &> "$CURRENT_LOG"

# --- Step 1: Pre-process Hints File (AWK FIX) ---
echo "1. Pre-processing hints file: Replacing '.' in GFF score column (field 6) with '0.0'..."

# Use awk to check the 6th field ($6). If it is a single '.', replace it with '0.0'.
awk 'BEGIN {OFS="\t"} {
    # Print header/comment lines unchanged
    if ($0 ~ /^#/) {
        print
        next
    }
    # Check if the 6th field is the placeholder '.'
    if ($6 == ".") {
        $6 = "0.0"
    }
    print
}' "$INPUT_HINTS" > "$TEMP_HINTS"

if [ $? -ne 0 ]; then
    echo "ERROR: AWK pre-processing of hints file failed (Step 1)."
    # Attempt to clean up temp file before exit
    rm -f "$TEMP_HINTS"
    exit 1
fi

# --- Step 2: Run TSEBRA ---
echo "2. Running TSEBRA to select best transcripts (using fixed hints file)..."

"$EXPANDED_TSEBRA_TOOL" \
    -g "$INPUT_GFF" \
    -e "$TEMP_HINTS" \
    -c "$CONFIG_FILE" \
    -o "$OUTPUT_GFF"

EXIT_CODE_TSEBRA=$?

# --- Step 3: Cleanup and Final Report ---
echo "3. Cleaning up intermediate fixed hints file: $TEMP_HINTS"
rm -f "$TEMP_HINTS"

echo -e "\n--- Pipeline Summary ---"

if [ "$EXIT_CODE_TSEBRA" -eq 0 ]; then
    echo "TSEBRA selection: SUCCESS"
    echo "Filtered GFF saved to: $OUTPUT_GFF"
    exit 0
else
    echo "ERROR: TSEBRA failed (Step 2, Exit Code $EXIT_CODE_TSEBRA). Review log for details." >&2
    exit 1
fi
