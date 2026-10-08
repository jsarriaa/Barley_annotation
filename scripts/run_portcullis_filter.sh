#!/bin/bash

# Define variables
GENOTYPE="GDB_136"
INPUT_TAB="portcullis/${GENOTYPE}.junctions.tab"
OUTPUT_PREFIX="portcullis/portcullis.flt"
INPUT_DIR="portcullis"
THREAD_COUNT=32
LOG_FILE="logs/${GENOTYPE}.portcullis_flt.log"

# Create logs directory if it doesn't exist
mkdir -p logs

echo "Starting Portcullis filtering for genotype: ${GENOTYPE}"
echo "Input junction file: ${INPUT_TAB}"
echo "Output prefix: ${OUTPUT_PREFIX}"

# Run the portcullis filter command
portcullis filter \
    -v \
    -t "${THREAD_COUNT}" \
    -o "${OUTPUT_PREFIX}" \
    "${INPUT_DIR}" \
    "${INPUT_TAB}" \
    &> "${LOG_FILE}"

# Check the exit status of the command
if [ $? -eq 0 ]; then
    echo "Portcullis filtering completed successfully. See ${LOG_FILE} for details."
else
    echo "Error during Portcullis filtering. Check ${LOG_FILE} for error messages."
fi
