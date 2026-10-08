#!/bin/bash

# Variables
GENOTYPE="GDB_136"
GENOME_DIR="STAR/"
THREAD_COUNT=32
MAX_INTRON=50000 # based on original repo value
BAM_SORT_RAM=3200000000 # based on original repo value
OUTPUT_DIR="STAR/alignments"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"
mkdir -p logs/STAR

# Define an array of sample identifiers
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

# Increase open file limit for STAR
ulimit -n 4096

# Loop through each sample and run STAR
for SAMPLE in "${SAMPLES[@]}"; do
    FQ1="data/mRNA-seq/Unknown_${SAMPLE}_1.fasta"
    FQ2="data/mRNA-seq/Unknown_${SAMPLE}_2.fasta"
    
    # Define output prefix
    OUT_PREFIX="${OUTPUT_DIR}/${SAMPLE}_"
    
    # Log file for the run
    LOG_FILE="logs/STAR/${GENOTYPE}.${SAMPLE}.mapping.log"
    
    echo "Running STAR for sample: ${SAMPLE}..."
    echo "Output will be saved to: ${OUT_PREFIX}Aligned.sortedByCoord.out.bam"
    
    # Run STAR.
    STAR \
        --genomeDir "$GENOME_DIR" \
        --runThreadN "$THREAD_COUNT" \
        --readFilesIn "$FQ1" "$FQ2" \
        --outFileNamePrefix "$OUT_PREFIX" \
        --outSAMtype BAM SortedByCoordinate \
        --outSAMstrandField intronMotif \
        --alignIntronMax "$MAX_INTRON" \
        --limitBAMsortRAM "$BAM_SORT_RAM" \
        --genomeLoad NoSharedMemory \
        &> "$LOG_FILE"
    
    echo "STAR completed for ${SAMPLE}. Check ${LOG_FILE} for details."
    echo "---"
done

echo "All STAR alignment jobs have been submitted."
