#!/bin/bash

# Define variables based on your Snakemake rule
GENOTYPE="GDB_136"
BAM_DIR="STAR/alignments/"
OUTPUT_BAM="STAR/alignments/allsamples.bam"
THREAD_COUNT=32
LOG_FILE="logs/${GENOTYPE}.sam_merge.log"

echo "Starting BAM file merge for genotype: ${GENOTYPE}"

# Find all BAM files to be merged
INPUT_FILES=$(find "${BAM_DIR}" -name "*.bam" | sort -n)

# Check if any BAM files were found
if [ -z "$INPUT_FILES" ]; then
    echo "No BAM files found in ${BAM_DIR}. Exiting."
    exit 1
fi

echo "Found the following BAM files to merge:"
echo "$INPUT_FILES"
echo "Merging files into ${OUTPUT_BAM} using ${THREAD_COUNT} threads."

# Run samtools merge command
samtools merge \
    -@ ${THREAD_COUNT} \
    ${OUTPUT_BAM} \
    ${INPUT_FILES} \
    &> "${LOG_FILE}"

# Check the exit status of the samtools command
if [ $? -eq 0 ]; then
    echo "BAM merging completed successfully. Check ${LOG_FILE} for details."
else
    echo "Error during BAM merging. See ${LOG_FILE} for error messages."
fi
