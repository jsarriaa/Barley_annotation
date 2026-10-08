#!/bin/bash

# This script maps Iso-Seq reads to a reference genome using minimap2 and samtools.

# --- USER-DEFINED VARIABLES ---
GENOTYPE="GDB_136"

# The sample name, e.g., "pacbio_reads_sample1"
SAMPLE="GDB_136_Isoseq"

# The full path to the input Iso-Seq reads file (FASTA or FASTQ)
READS_FASTA="data/IsoSeq.fa"

# Number of threads to use for both minimap2 and samtools
THREADS=32

# --- FILE PATHS ---
MMI_INDEX="minimap2_index/${GENOTYPE}.mmi"
JUNCTIONS_BED="portcullis/portcullis.flt.pass.junctions.bed"

# Output file
OUTPUT_BAM="data/Isoseq_${SAMPLE}.mm2.bam"

# Log file
LOG_FILE="logs/${GENOTYPE}.${SAMPLE}.minimap2.log"

# --- INPUT FILE CHECK ---
echo "Checking for required input files..."
if [ ! -f "$MMI_INDEX" ]; then
    echo "ERROR: Minimap2 index file not found: $MMI_INDEX" >&2
    exit 1
fi
if [ ! -f "$JUNCTIONS_BED" ]; then
    echo "ERROR: Junctions BED file not found: $JUNCTIONS_BED" >&2
    exit 1
fi
if [ ! -f "$READS_FASTA" ]; then
    echo "ERROR: Reads file not found: $READS_FASTA" >&2
    exit 1
fi
echo "All required input files found."

# --- MAIN COMMAND ---
echo "Starting minimap2 alignment for ${SAMPLE} to ${GENOTYPE}."
echo "Output will be piped to samtools sort."

# Create the output directory if it doesn't exist
mkdir -p "$(dirname "$OUTPUT_BAM")"

# The minimap2 command, piped to samtools sort
minimap2 \
    -ax splice:hq \
    --junc-bed "${JUNCTIONS_BED}" \
    --cs=long \
    -t ${THREADS} \
    -uf \
    -L \
    --eqx \
    -2 \
    --secondary=no \
    "${MMI_INDEX}" \
    "${READS_FASTA}" \
    | samtools sort -O BAM -@ ${THREADS} - > "${OUTPUT_BAM}" \
    2> "${LOG_FILE}"	# Only redirect the sterr, if not capturing what should be at the bam output

# Check the exit status of the command
if [ $? -eq 0 ]; then
    echo "Alignment and sorting completed successfully. Output saved to: ${OUTPUT_BAM}"
else
    echo "ERROR: minimap2 and/or samtools failed. Please check the log file: ${LOG_FILE}" >&2
    exit 1
fi
