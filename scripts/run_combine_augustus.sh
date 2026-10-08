#!/bin/bash
# Combines all individual AUGUSTUS GFF predictions into two master GFF and GFF3 files.

# --- Usage and Setup ---

GENOTYPE="GDB_136"
# Note: The 'aggregate_augustus' in the Snakemake rule implicitly represents the
# collection of all individual GFF files from the abinitio directory.

LOGS_DIR="logs"

# Input files/directories
ABINITIO_DIR="${GENOTYPE}/abinitio"
# CONTIGS_GFF="${GENOTYPE}/augustus.contigs.gff" # Removed as per your clarification (it is not generated yet)
# 						 # At snakemake is used if you come from contigs (not our case) so concatenating gff3 instead of this file

# Output files
OUTPUT_GFF="${GENOTYPE}/augustus.hints.all_combined.gff"
OUTPUT_GFF3="${GENOTYPE}/augustus.hints.all_combined.gff3"

# Temporary files
TEMP_LST="${GENOTYPE}/abinitio_pred.lst"
TEMP_GFF="${GENOTYPE}/augustus.tmp.gff"

# Log file for this specific step (based on Snakemake's log configuration)
CURRENT_LOG="${LOGS_DIR}/${GENOTYPE}.augustus_combine.log"

# --- Pre-run Checks ---

# Ensure all individual GFFs exist (checking the directory)
if [ ! -d "$ABINITIO_DIR" ] || [ -z "$(ls -A "$ABINITIO_DIR"/*.gff 2>/dev/null)" ]; then
    echo "Error: No individual AUGUSTUS GFF files found in $ABINITIO_DIR." >&2
    exit 1
fi

# Ensure log directory exists
mkdir -p "$LOGS_DIR"

echo "--- Starting AUGUSTUS Output Combination for Genotype: ${GENOTYPE} ---"
echo "Output GFF: ${OUTPUT_GFF}"
echo "Output GFF3: ${OUTPUT_GFF3}"
echo "Log: ${CURRENT_LOG}"

# Redirect all subsequent script output (stdout and stderr) to the main log file
# This will prevent future "silent" runs and ensure everything is logged.
exec &> "$CURRENT_LOG"

# --- Core Combination Steps (Translated from 'run' block) ---

echo "1. Generating list of all individual GFF files in $ABINITIO_DIR..."
# Snakemake shell: ls -1v {wildcards.genotype}/abinitio/*.gff > {wildcards.genotype}/abinitio_pred.lst
ls -1v "${ABINITIO_DIR}"/*.gff > "$TEMP_LST"

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create list of GFF files."
    exit 1
fi

echo "2. Concatenating all individual GFFs into a temporary file (using xargs to bypass argument list limit)..."
# FIX implemented here: Using xargs to safely handle a very long list of files.
# The previous problematic line (cat "$(cat "$TEMP_LST")" "$CONTIGS_GFF" > "$TEMP_GFF") is replaced.
xargs cat < "$TEMP_LST" > "$TEMP_GFF"

if [ $? -ne 0 ]; then
    echo "ERROR: xargs cat failed on GFF files list."
    rm -f "$TEMP_LST"
    exit 1
fi

echo "3. Joining redundant AUGUSTUS predictions using join_aug_pred.pl..."
# Snakemake shell: join_aug_pred.pl < {wildcards.genotype}/augustus.tmp.gff > {output.gff}
join_aug_pred.pl < "$TEMP_GFF" > "$OUTPUT_GFF"

if [ $? -ne 0 ]; then
    echo "ERROR: join_aug_pred.pl failed. Check tool availability and $CURRENT_LOG."
    # Attempt cleanup for temporary files
    rm -f "$TEMP_LST" "$TEMP_GFF"
    exit 1
fi

echo "4. Converting combined GFF to GFF3 format using gtf2gff.pl..."
# Snakemake shell: gtf2gff.pl < {output.gff} --gff3 --printExon --printUTR --out={output.gff3}
gtf2gff.pl \
    < "$OUTPUT_GFF" \
    --gff3 \
    --printExon \
    --printUTR \
    --out="$OUTPUT_GFF3"

if [ $? -ne 0 ]; then
    echo "ERROR: gtf2gff.pl failed. Check tool availability and $CURRENT_LOG."
    # Attempt cleanup for temporary files
    rm -f "$TEMP_LST" "$TEMP_GFF"
    exit 1
fi

# --- Final Cleanup and Report ---

echo "5. Cleaning up temporary files."
rm -f "$TEMP_LST" "$TEMP_GFF"

echo -e "\n--- Pipeline Summary ---"
echo "Combining augustus outputs: SUCCESS"
echo "Combined GFF saved to: $OUTPUT_GFF"
echo "Combined GFF3 saved to: $OUTPUT_GFF3"

exit 0
