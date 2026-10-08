#!/bin/bash
# run_convert_stringtie2EVM.sh
# Converts StringTie GTF output into the GFF3 alignment format required by EVidenceModeler (EVM) for transcript evidence.

# --- Usage and Setup ---

GENOTYPE="GDB_136"
LOGS_DIR="logs"

# === USER CONFIGURATION: Set the base directory for EVM ===
# You MUST change this path to point to the parent directory where EVidenceModeler-v2.1.0 is located.
EVM_BASE_DIR="/scratch/GDB136/new_anno" 
# =========================================================

# Input file (StringTie merged GTF)
INPUT_GTF="stringtie/stringtie.merged.junc_flt.gtf"

# Output file (EVM format for transcript alignments)
OUTPUT_EVM_GFF="${GENOTYPE}/evm.stringtie_transcripts.gff"

# Parameters
EVIDENCE_SOURCE="stringtie" # Name of the evidence source for EVM GFF
# Tool path (The Perl utility from EVM)
CONVERSION_TOOL="${EVM_BASE_DIR}/EVidenceModeler-v2.1.0/EvmUtils/misc/align_GTF_to_align_GFF3.pl"

# Log file for this specific step
CURRENT_LOG="${LOGS_DIR}/${GENOTYPE}.convert_transcripts2EVM.log"

# --- Pre-run Checks ---

# Expand base directory and tool path
EVM_BASE_DIR=$(eval echo "$EVM_BASE_DIR")
CONVERSION_TOOL=$(eval echo "$CONVERSION_TOOL") 

if [ ! -f "$INPUT_GTF" ]; then
    echo "Error: Input StringTie GTF file not found at $INPUT_GTF." >&2
    exit 1
fi
if [ ! -x "$CONVERSION_TOOL" ]; then
    echo "Error: Conversion tool not found or is not executable at $CONVERSION_TOOL." >&2
    exit 1
fi

# Ensure log directory exists
mkdir -p "$LOGS_DIR"

echo "--- Starting StringTie to EVM Transcript Alignment Conversion for Genotype: ${GENOTYPE} ---"
echo "Log: ${CURRENT_LOG}"

# Redirect all subsequent script output (stdout and stderr) to the main log file
exec &> "$CURRENT_LOG"

# --- Core Execution Step ---

echo "1. Running align_GTF_to_align_GFF3.pl utility..."

# Command: Conversion Tool <input.gtf> <source_name> > <output.gff>
"$CONVERSION_TOOL" "$INPUT_GTF" "$EVIDENCE_SOURCE" \
> "$OUTPUT_EVM_GFF"

EXIT_CODE=$?

# --- Final Report ---

echo -e "\n--- Pipeline Summary ---"
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "StringTie to EVM conversion: SUCCESS"
    echo "EVM GFF saved to: $OUTPUT_EVM_GFF"
    exit 0
else
    echo "ERROR: Conversion failed (Exit Code $EXIT_CODE). Check log for details." >&2
    exit 1
fi
