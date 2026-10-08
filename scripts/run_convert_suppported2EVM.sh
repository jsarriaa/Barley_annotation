#!/bin/bash
# run_convert_supported2EVM.sh
# Converts the supported AUGUSTUS GFF3 predictions into the specific GFF3 format required by EVidenceModeler (EVM).

# --- Usage and Setup ---

GENOTYPE="GDB_136"
LOGS_DIR="logs"

# === USER CONFIGURATION: Set the base directory for EVM ===
# You MUST change this path to point to the parent directory where EVidenceModeler-v2.1.0 is located.
EVM_BASE_DIR="/scratch/GDB136/new_anno" 
# Example: If EVM is in /home/user/tools/EVidenceModeler-v2.1.0, set this to /home/user/tools
# If the previous path (~/tools/...) was correct, set this to ~/tools
# EVM_BASE_DIR="~/tools" 
# =========================================================

# Input file (from the 'extract_supported' rule)
INPUT_GFF3="${GENOTYPE}/augustus.hints.all_combined.supported.gff3"

# Output file (EVM format)
OUTPUT_EVM_GFF="${GENOTYPE}/evm.abinitio.supported.gff"

# Tool path (Constructed using the base directory)
CONVERSION_TOOL="${EVM_BASE_DIR}/EVidenceModeler-v2.1.0/EvmUtils/misc/augustus_GFF3_to_EVM_GFF3.pl"

# Log file for this specific step
CURRENT_LOG="${LOGS_DIR}/${GENOTYPE}.convert_supported2EVM.log"

# --- Pre-run Checks ---

# Expand the base directory path (e.g., if it uses ~)
EVM_BASE_DIR=$(eval echo "$EVM_BASE_DIR")
CONVERSION_TOOL=$(eval echo "$CONVERSION_TOOL") # Re-evaluate to incorporate the expanded base path

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

echo "--- Starting AUGUSTUS to EVM Conversion for Genotype: ${GENOTYPE} ---"
echo "Conversion Tool Path: $CONVERSION_TOOL"
echo "Log: ${CURRENT_LOG}"

# Redirect all subsequent script output (stdout and stderr) to the main log file
exec &> "$CURRENT_LOG"

# --- Core Execution Step ---

echo "1. Running AUGUSTUS GFF3 conversion utility..."
echo "2. Piping output to sed to rename source from 'Augustus' to 'AUGSUPP'..."

# Pipeline: Conversion Tool -> sed -> Output File
"$CONVERSION_TOOL" "$INPUT_GFF3" \
| sed 's/Augustus/AUGSUPP/' \
> "$OUTPUT_EVM_GFF"

EXIT_CODE=$?

# --- Final Report ---

echo -e "\n--- Pipeline Summary ---"
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "AUGUSTUS to EVM conversion: SUCCESS"
    echo "EVM GFF saved to: $OUTPUT_EVM_GFF"
    exit 0
else
    echo "ERROR: Conversion failed (Exit Code $EXIT_CODE). Check log for details." >&2
    exit 1
fi
