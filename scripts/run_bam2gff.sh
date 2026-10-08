#!/bin/bash

# ==============================================================================
# 	       Converts a BAM file (from minimap2 long-read alignment) into 
#              BED, genePred (GP), GTF, and PSL formats using bedtools and 
#              UCSC utilities (bedToGenePred, genePredToGtf, bedToPsl).
# ==============================================================================

# --- Configuration Variables ---
GENOTYPE="GDB_136"
SAMPLE="GDB_136_Isoseq"

# Define directory variables
ISOSEQ_DIR="data/"
LOG_DIR="logs"

# --- Input/Output File Paths ---

# Input files
INPUT_BAM="${ISOSEQ_DIR}/Isoseq_${SAMPLE}.mm2.bam"
INPUT_FAI="data/${GENOTYPE}.fa.fai"

# Output files
OUTPUT_BED="${ISOSEQ_DIR}/${SAMPLE}.mm2.bed"
OUTPUT_GP="${ISOSEQ_DIR}/${SAMPLE}.mm2.gp"
OUTPUT_GTF="${ISOSEQ_DIR}/${SAMPLE}.mm2.gtf"
OUTPUT_PSL="${ISOSEQ_DIR}/${SAMPLE}.mm2.psl"

# Log file
LOG_FILE="${LOG_DIR}/${GENOTYPE}.${SAMPLE}.minimap2TOGTF.log"
LOG_ERR="${LOG_DIR}/${GENOTYPE}.${SAMPLE}.minimap2TOGTF.log.e"
LOG_OUT="${LOG_DIR}/${GENOTYPE}.${SAMPLE}.minimap2TOGTF.log.o"

# --- Resource and Metadata ---
NUM_THREADS=16
MEMORY_MB=8000	# As original snakemake
TIME_MINUTES=60 # As original snakemake

# --- Setup ---

# Ensure directories exist
mkdir -p "$ISOSEQ_DIR"
mkdir -p "$LOG_DIR"

# Clear previous log files before starting
> "$LOG_FILE"
> "$LOG_ERR"
> "$LOG_OUT"

# Function to check the exit status of the last command
check_status() {
    local exit_code=$?
    local command_name="$1"
    if [ $exit_code -ne 0 ]; then
        echo "--- ERROR: ${command_name} failed with exit code $exit_code ---" | tee -a "$LOG_FILE"
        echo "Please check the error log for details: $LOG_ERR" | tee -a "$LOG_FILE"
        exit $exit_code
    fi
}

# --- Main Workflow Execution ---

echo "Starting conversion for ${SAMPLE} (Genotype: ${GENOTYPE})" | tee -a "$LOG_FILE"
echo "Input BAM: ${INPUT_BAM}" | tee -a "$LOG_FILE"
echo "Output GTF: ${OUTPUT_GTF}" | tee -a "$LOG_FILE"

# 1. Check if input files exist
if [ ! -f "$INPUT_BAM" ]; then
    echo "ERROR: Input BAM file not found: $INPUT_BAM" | tee -a "$LOG_FILE"
    exit 1
fi
if [ ! -f "$INPUT_FAI" ]; then
    echo "ERROR: Input FAI index file not found: $INPUT_FAI" | tee -a "$LOG_FILE"
    exit 1
fi

# ----------------------------------------------------------------------
# STEP 1: BAM to BED12 conversion (bedtools bamtobed)
# ----------------------------------------------------------------------
echo "--- Step 1: Converting BAM to BED12 ---" | tee -a "$LOG_FILE"
bedtools bamtobed -bed12 \
  -i "$INPUT_BAM" \
  > "$OUTPUT_BED" 2>> "$LOG_ERR"
check_status "bedtools bamtobed"

# ----------------------------------------------------------------------
# STEP 2: BED to genePred conversion (bedToGenePred)
# ----------------------------------------------------------------------
echo "--- Step 2: Converting BED to genePred (GP) ---" | tee -a "$LOG_FILE"
bedToGenePred \
  "$OUTPUT_BED" \
  "$OUTPUT_GP" 2>> "$LOG_ERR"
check_status "bedToGenePred"

# ----------------------------------------------------------------------
# STEP 3: genePred to GTF conversion (genePredToGtf)
# ----------------------------------------------------------------------
echo "--- Step 3: Converting genePred to GTF ---" | tee -a "$LOG_FILE"
genePredToGtf file \
  -source=minimap2 \
  "$OUTPUT_GP" \
  "$OUTPUT_GTF" 2>> "$LOG_ERR"
check_status "genePredToGtf"

# ----------------------------------------------------------------------
# STEP 4: BED to PSL conversion (bedToPsl)
# ----------------------------------------------------------------------
echo "--- Step 4: Converting BED to PSL ---" | tee -a "$LOG_FILE"
bedToPsl \
  -keepQuery \
  "$INPUT_FAI" \
  "$OUTPUT_BED" \
  "$OUTPUT_PSL" 2>> "$LOG_ERR"
check_status "bedToPsl"

# ----------------------------------------------------------------------
# Completion Message
# ----------------------------------------------------------------------
echo "--- Conversion completed successfully ---" | tee -a "$LOG_FILE"
echo "Output files created:" | tee -a "$LOG_FILE"
echo "  BED: $OUTPUT_BED" | tee -a "$LOG_FILE"
echo "  GP:  $OUTPUT_GP" | tee -a "$LOG_FILE"
echo "  GTF: $OUTPUT_GTF" | tee -a "$LOG_FILE"
echo "  PSL: $OUTPUT_PSL" | tee -a "$LOG_FILE"

# Note: The logs for stdout are mixed between the main log file (for echo 
# messages) and the dedicated log files (for tool outputs).
# The original Snakemake rule used a single log file for everything. 
# This version separates tool errors to $LOG_ERR for cleaner debugging.

exit 0
