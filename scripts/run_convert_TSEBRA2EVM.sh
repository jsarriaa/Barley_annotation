#!/bin/bash
# run_convert_TSEBRA2EVM.sh
# Converts the TSEBRA-filtered GFF into the specific GFF3 format required by EVidenceModeler (EVM)
# and renames the source to 'TSEBRA'.

# --- Usage and Setup ---

GENOTYPE="GDB_136"
LOGS_DIR="logs"

# === USER CONFIGURATION: Set the base directory for EVM ===
# You MUST change this path to point to the parent directory where EVidenceModeler-v2.1.0 is located.
EVM_BASE_DIR="/scratch/GDB136/new_anno" 
# =========================================================

# Input file (TSEBRA output GFF/GTF)
INPUT_GFF="${GENOTYPE}/augustus.hints.all_combined.tsebra.gff"

# Output file (EVM format)
OUTPUT_EVM_GFF="${GENOTYPE}/evm.abinitio.tsebra.gff"

# Tool path (The tool used here is augustus_GTF_to_EVM_GFF3.pl, note GTF instead of GFF3)
CONVERSION_TOOL="${EVM_BASE_DIR}/EVidenceModeler-v2.1.0/EvmUtils/misc/augustus_GTF_to_EVM_GFF3.pl"

# Log file for this specific step
CURRENT_LOG="${LOGS_DIR}/${GENOTYPE}.convert_tsebra2EVM.log"

# --- Pre-run Checks ---

# Expand base directory and tool path
EVM_BASE_DIR=$(eval echo "$EVM_BASE_DIR")
CONVERSION_TOOL=$(eval echo "$CONVERSION_TOOL") 

if [ ! -f "$INPUT_GFF" ]; then
    echo "Error: Input GFF file not found at $INPUT_GFF." >&2
    exit 1
fi
if [ ! -x "$CONVERSION_TOOL" ]; then
    echo "Error: Conversion tool not found or is not executable at $CONVERSION_TOOL." >&2
    exit 1
fi

# Ensure log directory exists
mkdir -p "$LOGS_DIR"

echo "--- Starting TSEBRA to EVM Conversion for Genotype: ${GENOTYPE} ---"
echo "Log: ${CURRENT_LOG}"

# Redirect all subsequent script output (stdout and stderr) to the main log file
exec &> "$CURRENT_LOG"

# --- Core Execution Step ---

echo "1. Running AUGUSTUS/TSEBRA GTF to EVM GFF3 conversion utility..."
echo "2. Piping output to sed to rename source from 'Augustus' to 'TSEBRA'..."

# Pipeline: Conversion Tool -> sed -> Output File
"$CONVERSION_TOOL" "$INPUT_GFF" \
| sed 's/Augustus/TSEBRA/' \
> "$OUTPUT_EVM_GFF"

EXIT_CODE=$?

# --- Final Report ---

echo -e "\n--- Pipeline Summary ---"
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "TSEBRA to EVM conversion: SUCCESS"
    echo "EVM GFF saved to: $OUTPUT_EVM_GFF"
    exit 0
else
    echo "ERROR: Conversion failed (Exit Code $EXIT_CODE). Check log for details." >&2
    exit 1
fi
