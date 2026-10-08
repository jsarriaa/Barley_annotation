#!/bin/bash
# Script to run DIAMOND blastx to align transcripts to a protein database.

# --- Define File Paths and Parameters ---
GENOTYPE="GDB_136"
NUM_THREADS=32

BLASTFASTA="data/uniref50.fasta"
DIAMOND_DB="transcripts/uniref50.fasta.dmnd"
### !!!!!

# Input file
INPUT_FASTA="transcripts/${GENOTYPE}_mikado_prepared.fasta"

# Output file
OUTPUT_BLX="transcripts/${GENOTYPE}_blast_sensitive.mikado_transcripts.tsv.gz"

# Logging
LOG_FILE="logs/${GENOTYPE}.blofelding.log"

# --- Main Command ---

# Create necessary directories
mkdir -p "logs"
mkdir -p "${GENOTYPE}/transcripts"

echo "Starting DIAMOND blastx for ${GENOTYPE}." | tee -a "$LOG_FILE"
echo "Input FASTA: ${INPUT_FASTA}" | tee -a "$LOG_FILE"
echo "Output TSV: ${OUTPUT_BLX}" | tee -a "$LOG_FILE"
echo "Database: ${DIAMOND_DB}" | tee -a "$LOG_FILE"
echo "Threads: ${NUM_THREADS}" | tee -a "$LOG_FILE"
echo "--- Starting DIAMOND blastx ---" | tee -a "$LOG_FILE"

# Check for required input files
if [ ! -f "$INPUT_FASTA" ]; then
    echo "ERROR: Input FASTA file not found: $INPUT_FASTA" | tee -a "$LOG_FILE"
    exit 1
fi

if [ ! -f "$DIAMOND_DB" ]; then
    echo "ERROR: DIAMOND database file not found: $DIAMOND_DB" | tee -a "$LOG_FILE"
    echo "Please create it using 'diamond makedb --in ${BLASTFASTA} -d ${DIAMOND_DB}'" | tee -a "$LOG_FILE"
    exit 1
fi

# Run the diamond command and redirect all output to the log file
diamond blastx \
    --threads "$NUM_THREADS" \
    --query "$INPUT_FASTA" \
    --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore ppos btop \
    --max-target-seqs 10 \
    --matrix blosum62 \
    --evalue 1.0e-03 \
    --db "$DIAMOND_DB" \
    --salltitles \
    --sensitive \
    --compress 1 \
    --out "$OUTPUT_BLX" &>> "$LOG_FILE"

# Check the exit status of the diamond command
if [ $? -eq 0 ]; then
    echo "--- DIAMOND blastx completed successfully for ${GENOTYPE} ---" | tee -a "$LOG_FILE"
    echo "Output saved to: ${OUTPUT_BLX}" | tee -a "$LOG_FILE"
else
    echo "--- ERROR: DIAMOND blastx failed for ${GENOTYPE} ---" | tee -a "$LOG_FILE"
    echo "Please check the log file for details: ${LOG_FILE}" | tee -a "$LOG_FILE"
    exit 1
fi
