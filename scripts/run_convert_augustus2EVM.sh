#!/bin/bash
# run_convert_augustus2EVM.sh
# Converts the unfiltered combined AUGUSTUS GFF3 predictions into the GFF3 format required by EVidenceModeler (EVM).

# --- Usage and Setup ---

GENOTYPE="GDB_136"
LOGS_DIR="logs"

# === USER CONFIGURATION: Set the base directory for EVM ===
# You MUST change this path to point to the parent directory where EVidenceModeler-v2.1.0 is located.
EVM_BASE_DIR="/scratch/GDB136/new_anno" 
# You should update this to your actual path if it's different.
# =========================================================

# Input file (Unfiltered combined GFF3)
INPUT_GFF3="${GENOTYPE}/augustus.hints.all_combined.gff3"

# Output file (EVM ab initio format, source will be 'AUGUSTUS')
OUTPUT_EVM_GFF="${GENOTYPE}/evm.abinitio.gff"

# Tool path (Constructed using the base directory)
CONVERSION_TOOL="${EVM_BASE_DIR}/EVidenceModeler-v2.1.0/EvmUtils/misc/augustus_GFF3_to_EVM_GFF3.pl"

# Log file for this specific step
CURRENT_LOG="${LOGS_DIR}/${GENOTYPE}.convert_augustus2EVM.log"

# --- Pre-run Checks ---

# Expand base directory and tool path
EVM_BASE_DIR=$(eval echo "$EVM_BASE_DIR")
CONVERSION_TOOL=$(eval echo "$CONVERSION_TOOL") 

if [ ! -f "$INPUT_GFF3" ]; then
    echo "Error: Input GFF3 file not found at $INPUT_GFF3." >&2
    exit 1
fi
if [ ! -x "$CONVERSION_TOOL" ]; then
    echo "Error: Conversion tool not found or is not executable at $CONVERSION_TOOL." >&2
    exit 1
fi

# Ensure log directory exists
mkdir -p "$LOGS_DIR"

echo "--- Starting Unfiltered AUGUSTUS to EVM Conversion for Genotype: ${GENOTYPE} ---"
echo "Log: ${CURRENT_LOG}"

# Redirect all subsequent script output (stdout and stderr) to the main log file
exec &> "$CURRENT_LOG"

# --- Core Execution Step ---

echo "1. Running AUGUSTUS GFF3 conversion utility..."
echo "Note: The output source will remain 'AUGUSTUS' (no 'sed' renaming is applied)."

# Pipeline: Conversion Tool -> Output File
# This command converts the GFF3 and writes directly to the output file.
"$CONVERSION_TOOL" "$INPUT_GFF3" \
> "$OUTPUT_EVM_GFF"

EXIT_CODE=$?

# --- Final Report ---

echo -e "\n--- Pipeline Summary ---"
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "Unfiltered AUGUSTUS to EVM conversion: SUCCESS"
    echo "EVM GFF saved to: $OUTPUT_EVM_GFF"
    exit 0
else
    echo "ERROR: Conversion failed (Exit Code $EXIT_CODE). Check log for details." >&2
    exit 1
fi
