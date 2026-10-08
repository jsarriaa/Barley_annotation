#!/bin/bash
# run_removeELM.sh
# Filters the final EVM GFF3 output to remove Transposable Element-Like (ELM) predictions.

# --- Configuration (Must match your environment and previous runs) ---
GENOTYPE="GDB_136"
RUN="run2"
# The EVM GFF3 output file from the previous step
INPUT_EVM="${GENOTYPE}/${GENOTYPE}.${RUN}.EVM.gff3"

# The desired output file name (EVM with ELM annotations removed)
OUTPUT_EVM="${GENOTYPE}/${GENOTYPE}.${RUN}.EVM.no_ELM.gff3"

LOG_FILE="logs/${GENOTYPE}.evm_removeELM.log"

# --- Pre-run Checks and Setup ---

# Ensure logs directory exists and input file is present
mkdir -p logs
if [ ! -f "$INPUT_EVM" ]; then
    echo "Error: Input EVM file not found: $INPUT_EVM" >&2
    exit 1
fi

echo "--- Starting ELM Removal for ${GENOTYPE} ---"
echo "Input: $INPUT_EVM"
echo "Output: $OUTPUT_EVM"
echo "Log: $LOG_FILE"
echo ""

# Redirect standard output and standard error to the log file
exec &> "$LOG_FILE"

# --- Core Execution Step ---

# The shell command from the Snakemake rule:
# grep -Pv "\tEVM_elm\t" {input.evm} > {output.evm} 

# grep -P (Perl regex) -v (invert match/print non-matching lines)
# It searches for the tab-delimited string "EVM_elm" in the source column (column 2)
# and removes those lines.

echo "Running grep command to remove EVM_elm lines..."

grep -Pv "\tEVM_elm\t" "$INPUT_EVM" > "$OUTPUT_EVM"

EXIT_CODE=$?

# --- Final Report ---

if [ "$EXIT_CODE" -eq 0 ]; then
    echo "Successfully filtered ELM annotations."
    echo "Final file size:"
    # This command checks the size of the new file
    ls -lh "$OUTPUT_EVM"
    exit 0
else
    echo "ERROR: ELM removal failed (Exit Code $EXIT_CODE). Review log for details." >&2
    exit 1
fi
