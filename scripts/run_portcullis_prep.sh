#!/bin/bash

# Define variables based on your Snakemake rule
GENOTYPE="GDB_136"
BAM_FILE="STAR/alignments/allsamples.bam"
FASTA_FILE="data/GDB_136.fa"
OUTPUT_DIR="portcullis"
THREAD_COUNT=32
LOG_FILE="logs/${GENOTYPE}.portcullis_prep.log"

# Create necessary directories
mkdir -p "${OUTPUT_DIR}"
mkdir -p logs

echo "Starting Portcullis preparation for genotype: ${GENOTYPE}"
echo "Input BAM: ${BAM_FILE}"
echo "Input FASTA: ${FASTA_FILE}"
echo "Output will be saved to: ${OUTPUT_DIR}"

# Run the portcullis prep command
portcullis prep \
    -c \
    -t "${THREAD_COUNT}" \
    "${FASTA_FILE}" \
    "${BAM_FILE}" \
    -o "${OUTPUT_DIR}" \
    &> "${LOG_FILE}"

# Check the exit status of the portcullis command
if [ $? -eq 0 ]; then
    echo "Portcullis preparation completed successfully. See ${LOG_FILE} for details."
else
    echo "Error during Portcullis preparation. Check ${LOG_FILE} for error messages."
fi
