#!/bin/bash

# Define variables based on your Snakemake rule
GENOTYPE="GDB_136"
INPUT_DIR="portcullis"
OUTPUT_PREFIX="portcullis/${GENOTYPE}"
THREAD_COUNT=32
LOG_FILE="logs/${GENOTYPE}.portcullis_junc.log"

# Create logs directory if it doesn't exist
mkdir -p logs

echo "Starting Portcullis junction analysis for genotype: ${GENOTYPE}"
echo "Input directory: ${INPUT_DIR}"
echo "Output prefix: ${OUTPUT_PREFIX}"

# Run the portcullis junc command
portcullis junc \
    -c \
    -v \
    -t "${THREAD_COUNT}" \
    -o "${OUTPUT_PREFIX}" \
    "${INPUT_DIR}" \
    &> "${LOG_FILE}"

# Check the exit status of the command
if [ $? -eq 0 ]; then
    echo "Portcullis junction analysis completed successfully. See ${LOG_FILE} for details."
else
    echo "Error during Portcullis junction analysis. Check ${LOG_FILE} for error messages."
fi
