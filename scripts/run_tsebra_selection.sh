#!/bin/bash
# run_tsebra_selection.sh
# Runs TSEBRA to select the best AUGUSTUS transcripts and converts the output to GFF3.
# FIX 1: Includes an AWK step to replace '.' with '0.0' in the hints GFF score column,
#         which fixes the 'ValueError: could not convert string to float: '.' error.
# FIX 2: Normalizes bare transcript IDs to GTF-style attributes on transcript lines only.
#         Exon/CDS/tss/tts lines already have valid GTF attributes and are left untouched.
# NOTE:   The raw TSEBRA GFF output is kept permanently (not deleted).

# --- Usage and Setup ---
GENOTYPE="GDB_136"
LOGS_DIR="logs"

# Input files
INPUT_GFF_ALL="${GENOTYPE}/augustus.hints.all_combined.gff"
INPUT_HINTS="${GENOTYPE}/hints.all_combined.gff"
CONFIG_FILE="pananno/pananno.cfg"

# Tool path
TSEBRA_TOOL="/scratch/software-phgv2/miniconda3/envs/pananno/bin/tsebra.py"
EXPANDED_TSEBRA_TOOL=$(eval echo "$TSEBRA_TOOL")

# Temporary files (deleted after successful run)
TEMP_HINTS="${GENOTYPE}/hints.all_combined.fixed.gff"
OUTPUT_GFF_NORMALIZED="${GENOTYPE}/augustus.hints.all_combined.tsebra.normalized.gff"

# Kept output files
OUTPUT_GFF_TEMP="${GENOTYPE}/augustus.hints.all_combined.tsebra.gff"   # kept permanently
OUTPUT_GFF3="${GENOTYPE}/augustus.hints.all_combined.tsebra.gff3"      # final output

# Log file
CURRENT_LOG="${LOGS_DIR}/${GENOTYPE}.augustus.tsebra.log"

# --- Pre-run Checks ---
if [ ! -f "$INPUT_GFF_ALL" ] || [ ! -f "$INPUT_HINTS" ] || [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: One or more input/config files are missing." >&2
    echo "Checked files: $INPUT_GFF_ALL, $INPUT_HINTS, $CONFIG_FILE" >&2
    exit 1
fi

if [ ! -x "$EXPANDED_TSEBRA_TOOL" ]; then
    echo "Error: TSEBRA tool not found or is not executable at $EXPANDED_TSEBRA_TOOL." >&2
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
awk 'BEGIN {OFS="\t"} {
    if ($0 ~ /^#/) {
        print
        next
    }
    if ($6 == ".") {
        $6 = "0.0"
    }
    print
}' "$INPUT_HINTS" > "$TEMP_HINTS"

if [ $? -ne 0 ]; then
    echo "ERROR: AWK pre-processing of hints file failed."
    exit 1
fi
echo "Hints file pre-processing complete: $TEMP_HINTS"

# --- Step 2: Run TSEBRA to select the best transcripts ---
echo "2. Running TSEBRA to select best transcripts (using fixed hints file)..."
"$EXPANDED_TSEBRA_TOOL" \
    -g "$INPUT_GFF_ALL" \
    -e "$TEMP_HINTS" \
    -c "$CONFIG_FILE" \
    -o "$OUTPUT_GFF_TEMP"

EXIT_CODE_TSEBRA=$?
if [ "$EXIT_CODE_TSEBRA" -ne 0 ]; then
    echo "ERROR: TSEBRA failed (Step 2, Exit Code $EXIT_CODE_TSEBRA). Review log for details."
else
    echo "TSEBRA completed successfully."
    echo "TSEBRA raw GFF saved at: $OUTPUT_GFF_TEMP"
fi

# --- Step 3a: Normalize transcript lines to GTF attribute format ---
# Transcript lines have a bare ID in col 9 (e.g. "anno1.g2.t1").
# All other feature lines (exon, CDS, tss, tts) already have valid GTF attributes
# and are passed through unchanged.
echo "3a. Normalizing transcript lines to GTF attribute format..."
awk 'BEGIN{OFS="\t"} /^#/{print; next} {
    if ($3 == "transcript" && $9 !~ /;/) {
        id = $9
        gsub(/^[ \t]+|[ \t]+$/, "", id)  # trim whitespace
        gene_id = id
        sub(/\.t[0-9]+$/, "", gene_id)   # strip .tN suffix to get gene_id
        $9 = "transcript_id \"" id "\"; gene_id \"" gene_id "\";"
    }
    print
}' "$OUTPUT_GFF_TEMP" > "$OUTPUT_GFF_NORMALIZED"

if [ $? -ne 0 ]; then
    echo "ERROR: Normalization of TSEBRA GFF attributes failed."
    echo "Intermediate files kept for debugging:"
    echo "   TSEBRA raw output: $OUTPUT_GFF_TEMP"
    echo "   Fixed hints:       $TEMP_HINTS"
    exit 1
fi
echo "Normalization complete: $OUTPUT_GFF_NORMALIZED"

# Sanity check: transcript counts before and after normalization must match
COUNT_BEFORE=$(grep -c $'\ttranscript\t' "$OUTPUT_GFF_TEMP" || true)
COUNT_AFTER=$(grep -c $'\ttranscript\t' "$OUTPUT_GFF_NORMALIZED" || true)
echo "Transcript count in TSEBRA raw output:  $COUNT_BEFORE"
echo "Transcript count after normalization:   $COUNT_AFTER"
if [ "$COUNT_BEFORE" -ne "$COUNT_AFTER" ]; then
    echo "WARNING: Transcript count changed during normalization. Check $OUTPUT_GFF_NORMALIZED."
fi

# --- Step 3b: Convert normalized GFF to GFF3 format ---
echo "3b. Converting normalized GFF to GFF3 using gffread..."
gffread "$OUTPUT_GFF_NORMALIZED" \
    -O \
    -o "$OUTPUT_GFF3"

EXIT_CODE_GFFREAD=$?
if [ "$EXIT_CODE_GFFREAD" -ne 0 ]; then
    echo "ERROR: gffread conversion failed (Step 3b, Exit Code $EXIT_CODE_GFFREAD). Check log for details."
else
    echo "gffread conversion complete: $OUTPUT_GFF3"

    # Sanity check: mRNA count in GFF3 should match transcript count from TSEBRA
    COUNT_GFF3=$(grep -c $'\tmRNA\t' "$OUTPUT_GFF3" || true)
    echo "mRNA count in final GFF3:             $COUNT_GFF3"
    if [ "$COUNT_BEFORE" -ne "$COUNT_GFF3" ]; then
        echo "WARNING: mRNA count in GFF3 ($COUNT_GFF3) differs from TSEBRA transcript count ($COUNT_BEFORE)."
        echo "         Some records may have been dropped by gffread. Check warnings above."
    else
        echo "Transcript count check PASSED: $COUNT_GFF3 mRNAs in GFF3."
    fi
fi

# --- Step 4: Final Cleanup and Report ---
if [ "$EXIT_CODE_TSEBRA" -eq 0 ] && [ "$EXIT_CODE_GFFREAD" -eq 0 ]; then
    echo "4. Cleaning up intermediate files..."
    rm -f "$OUTPUT_GFF_NORMALIZED" "$TEMP_HINTS"
    echo "   Removed: $OUTPUT_GFF_NORMALIZED"
    echo "   Removed: $TEMP_HINTS"
    echo "   Kept:    $OUTPUT_GFF_TEMP  (TSEBRA raw GFF)"
    echo "   Kept:    $OUTPUT_GFF3      (final GFF3)"
else
    echo "4. Skipping cleanup due to errors. All intermediate files kept for debugging:"
    echo "   TSEBRA raw output:    $OUTPUT_GFF_TEMP"
    echo "   Normalized GFF:       $OUTPUT_GFF_NORMALIZED"
    echo "   Fixed hints:          $TEMP_HINTS"
fi

echo -e "\n--- Pipeline Summary ---"
if [ "$EXIT_CODE_TSEBRA" -eq 0 ] && [ "$EXIT_CODE_GFFREAD" -eq 0 ]; then
    echo "TSEBRA selection and conversion: SUCCESS"
    echo "TSEBRA raw GFF:    $OUTPUT_GFF_TEMP"
    echo "Final annotation:  $OUTPUT_GFF3"
    exit 0
else
    echo "TSEBRA selection and conversion: FAILED" >&2
    echo "Please check the log file: $CURRENT_LOG" >&2
    exit 1
fi
