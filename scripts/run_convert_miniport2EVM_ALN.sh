#!/bin/bash
# run_convert_miniport2EVM_ALN.sh
# Converts Miniprot GFF output into the GFF3 format required by EVidenceModeler (EVM) for protein alignment evidence.

# --- Usage and Setup ---

GENOTYPE="GDB_136"
LOGS_DIR="logs"

# === USER CONFIGURATION: Set the base directory for EVM ===
# You MUST change this path to point to the parent directory where EVidenceModeler-v2.1.0 is located.
EVM_BASE_DIR="/scratch/GDB136/new_anno" 
# =========================================================

# Input file (Miniprot GFF output)
INPUT_GFF="miniprot/${GENOTYPE}.uniref_plants_c50.miniprot_scored.gff"

# Output file (EVM format for protein alignments)
OUTPUT_EVM_GFF="${GENOTYPE}/evm.uniref_plants_c50.miniprot_aln.gff"

# Tool path (The Python utility from EVM)
CONVERSION_TOOL="${EVM_BASE_DIR}/EVidenceModeler-v2.1.0/EvmUtils/misc/miniprot_GFF_2_EVM_alignment_GFF3.py"

# Log file for this specific step
CURRENT_LOG="${LOGS_DIR}/${GENOTYPE}.convert_miniprot2EVM.log"

# --- Pre-run Checks ---

# Expand base directory and tool path
EVM_BASE_DIR=$(eval echo "$EVM_BASE_DIR")
CONVERSION_TOOL=$(eval echo "$CONVERSION_TOOL") 

if [ ! -f "$INPUT_GFF" ]; then
    echo "Error: Input Miniprot GFF file not found at $INPUT_GFF." >&2
    exit 1
fi
if [ ! -x "$CONVERSION_TOOL" ]; then
    echo "Error: Conversion tool not found or is not executable at $CONVERSION_TOOL." >&2
    exit 1
fi

# Ensure log directory exists
mkdir -p "$LOGS_DIR"

echo "--- Starting Miniprot to EVM Protein Alignment Conversion for Genotype: ${GENOTYPE} ---"
echo "Log: ${CURRENT_LOG}"

# Redirect all subsequent script output (stdout and stderr) to the main log file
exec &> "$CURRENT_LOG"

# --- Core Execution Step ---

echo "1. Running miniprot_GFF_2_EVM_alignment_GFF3.py utility..."

# Pipeline: Conversion Tool -> Output File
# This command converts the Miniprot GFF and writes directly to the output file.
python "$CONVERSION_TOOL" "$INPUT_GFF" \
> "$OUTPUT_EVM_GFF"

EXIT_CODE=$?

# --- Final Report ---

echo -e "\n--- Pipeline Summary ---"
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "Miniprot to EVM conversion: SUCCESS"
    echo "EVM GFF saved to: $OUTPUT_EVM_GFF"
    exit 0
else
    echo "ERROR: Conversion failed (Exit Code $EXIT_CODE). Check log for details." >&2
    exit 1
fi
