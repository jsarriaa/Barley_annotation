#!/bin/bash

# This script performs the 'gffread' step to extract CDS sequences.

# --- USER-DEFINED VARIABLES ---
GENOTYPE="GDB_136"
RUN="RUN1"
THREADS=32

# --- FILE PATHS AND PARAMETERS ---
# Input files
LOCI_GFF3="mikado/${GENOTYPE}.mikado_refined_prediction.${RUN}.loci.gff3"
GENOME_FASTA="data/${GENOTYPE}.fa"

# Output file
CDS_FASTA="transcripts/${GENOTYPE}_mikado_transcripts.loci.cds.fa"

# Log file
LOG_FILE="logs/${GENOTYPE}.mikado.transcripts_mik.write_cds.log"

# --- INPUT FILE CHECK ---
echo "Checking for required input files..."

# Check if the loci GFF3 file exists
if [ ! -f "$LOCI_GFF3" ]; then
    echo "ERROR: Loci GFF3 file not found: $LOCI_GFF3" >&2
    exit 1
fi

# Check if the genome FASTA file exists
if [ ! -f "$GENOME_FASTA" ]; then
    echo "ERROR: Genome FASTA file not found: $GENOME_FASTA" >&2
    exit 1
fi

echo "All required input files found."

# --- MAIN COMMAND ---
echo "Starting gffread to write CDS for genotype: ${GENOTYPE}"

# Create the output directory if it doesn't exist
mkdir -p "$(dirname "$CDS_FASTA")"

# The core `gffread` command
gffread \
    -g "${GENOME_FASTA}" \
    "${LOCI_GFF3}" \
    -x "${CDS_FASTA}" \
    &> "${LOG_FILE}"

# Check the exit status of the command
if [ $? -eq 0 ]; then
    echo "gffread completed successfully. CDS sequences saved to: ${CDS_FASTA}"
else
    echo "ERROR: gffread failed. Please check the log file: ${LOG_FILE}" >&2
    exit 1
fi
