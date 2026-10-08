#!/bin/bash

# Variables
GENOME_FASTA="data/GDB_136.fa"
GENOME_DIR="STAR"
TMP_DIR="temp/"

THREADS=32
RAM_LIMIT=512000000000	#As they used for panbarlex

# Create directories if not existing
mkdir -p "$GENOME_DIR"
mkdir -p "$TMP_DIR"

if [ -d "$TMP_DIR" ]; then
    echo "Removing old temporary directory: $TMP_DIR"
    rm -rf "$TMP_DIR"
fi

mkdir -p logs

# Set STAR parameters using same as github repo used to annotate panbarlex
genomeChrBinNbits='18'
genomeSAindexNbases='13'

echo "start to run STAR command"

# Run STAR genomeGenerate
STAR --runThreadN "$THREADS" \
     --runMode genomeGenerate \
     --genomeDir "$GENOME_DIR" \
     --genomeFastaFiles "$GENOME_FASTA" \
     --outTmpDir "$TMP_DIR" \
     --genomeChrBinNbits "$genomeChrBinNbits" \
     --genomeSAindexNbases "$genomeSAindexNbases" \
     --limitGenomeGenerateRAM "$RAM_LIMIT" \
     > logs/star_genomeGenerate_run.log 2>&1
