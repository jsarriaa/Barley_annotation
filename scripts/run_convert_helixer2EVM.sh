#!/bin/bash
# Description: Converts Helixer GFF3 predictions into the EVM-specific GFF3 format 
# and renames the source ID to 'HELIXER' for EVM.
# Requirements: The Augustus-to-EVM conversion Perl script must be in the specified path.

# --- USER-DEFINED VARIABLES ---
GENOTYPE="GDB_136"
# !!! IMPORTANT: VERIFY THIS PATH !!!
EVM_PERL_SCRIPT="/scratch/GDB136/new_anno/EVidenceModeler-v2.1.0/EvmUtils/misc/augustus_GFF3_to_EVM_GFF3.pl"

# --- FILE PATHS ---
INPUT_GFF="${GENOTYPE}/${GENOTYPE}.helixer.combined.gff3"
OUTPUT_GFF="${GENOTYPE}/evm.abinitio.helixer.gff"

LOG_FILE="logs/${GENOTYPE}.convert_helixer2EVM.log"

# --- SETUP AND INPUT CHECK ---
mkdir -p logs

if [ ! -f "$INPUT_GFF" ]; then
    echo "ERROR: Input Helixer GFF file not found: $INPUT_GFF" | tee "$LOG_FILE"
    exit 1
fi

echo "--- Starting GFF conversion for EVM (Helixer) for ${GENOTYPE} ---" | tee "$LOG_FILE"
echo "Input: $INPUT_GFF" | tee -a "$LOG_FILE"
echo "Output: $OUTPUT_GFF" | tee -a "$LOG_FILE"

# --- CORE EXECUTION ---

# The shell command runs the conversion script, pipes the output to sed for renaming the source to HELIXER, 
# and redirects the final output to the target file.
"${EVM_PERL_SCRIPT}" "${INPUT_GFF}" 2>&1 \
| sed 's/Augustus/HELIXER/g' \
> "${OUTPUT_GFF}"

EXIT_CODE=$?

# --- FINAL REPORT ---
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "--- SUCCESS: GFF conversion (Helixer) completed ---" | tee -a "$LOG_FILE"
else
    echo "--- ERROR: GFF conversion (Helixer) failed (Exit Code: $EXIT_CODE). ---" | tee -a "$LOG_FILE"
    echo "Check the log file and ensure the Perl script path is correct." | tee -a "$LOG_FILE"
    exit 1
fi

exit $EXIT_CODE
