#!/bin/bash

# Define variables
GENOTYPE="GDB_136"
THREAD_COUNT=32
OUTPUT_DIR="stringtie"

# List of all samples
SAMPLES=(
    "CP851-001U0001"
    "CP851-001U0002"
    "CP851-001U0003"
    "CP851-001U0004"
    "CP851-001U0005"
    "CP851-001U0006"
    "CP851-001U0007"
    "CP851-001U0008"
    "CP851-001U0009"
    "CP851-001U0010"
    "CP851-001U0011"
    "CP851-001U0012"
    "CP851-001U0013"
    "CP851-001U0014"
    "CP851-001U0015"
)

# Create necessary directories if they don't exist
mkdir -p "${OUTPUT_DIR}"
mkdir -p logs/stringtie

# Loop through each sample and run StringTie
for SAMPLE in "${SAMPLES[@]}"; do
    INPUT_BAM="STAR/alignments/${SAMPLE}_Aligned.sortedByCoord.out.bam"
    OUTPUT_GTF="${OUTPUT_DIR}/${SAMPLE}.stringtie.gtf"
    LOG_FILE="logs/stringtie/${GENOTYPE}.${SAMPLE}.stringtie.log"

    echo "Assembling transcripts for sample: ${SAMPLE}..."
    echo "Input BAM: ${INPUT_BAM}"
    echo "Output GTF: ${OUTPUT_GTF}"

    # Check if the input BAM file exists
    if [ ! -f "${INPUT_BAM}" ]; then
        echo "Error: Input BAM file not found: ${INPUT_BAM}"
        continue # Skip to the next sample
    fi

    # Run the stringtie command
    stringtie \
        -m 150 \
        -t \
        -f 0.3 \
        -p "${THREAD_COUNT}" \
        "${INPUT_BAM}" \
        -o "${OUTPUT_GTF}" \
        &> "${LOG_FILE}"

    # Check the exit status of the stringtie command
    if [ $? -eq 0 ]; then
        echo "StringTie assembly for ${SAMPLE} completed successfully. See ${LOG_FILE} for details."
    else
        echo "Error during StringTie assembly for ${SAMPLE}. Check ${LOG_FILE} for error messages."
    fi
    echo "---"
done

echo "All StringTie jobs have been completed."
