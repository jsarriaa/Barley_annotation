#!/bin/bash

# This script performs the 'mikado serialise' step.
# Before running, please set the following variables:
# 1. The genotype name, which serves as a wildcard in the file paths.
# 2. The path to your BLAST database FASTA file.

# --- USER-DEFINED VARIABLES ---
GENOTYPE="GDB_136"

# The path to the BLAST database FASTA file
BLASTFASTA="data/uniref50.fasta"

THREADS=32

BLX="$transcripts/${GENOTYPE}_blast_sensitive.mikado_transcripts.tsv.gz"
ORFS="transcripts/${GENOTYPE}_mikado_transcripts.orfs.gff"
YAML="transcripts/${GENOTYPE}.mikado.config.yaml"
FASTA="transcripts/${GENOTYPE}_mikado_prepared.fasta"
GTF="transcripts/${GENOTYPE}_mikado_prepared.gtf"		# This is actually not used directly, but mikado needs it and automatically search for it with same basename as the fasta
JUNC="portcullis/${GENOTYPE}.junctions.bed"
# Output:
DB="transcripts/${GENOTYPE}_mikado.db"

# Log file
LOG_FILE="logs/${GENOTYPE}.mikado.transcripts_mik.serialise.log"

# --- MAIN COMMAND ---
echo "Starting mikado serialise for genotype: ${GENOTYPE}"

# The core `mikado` command, with all parameters from the Snakemake rule
mikado serialise \
    -p ${THREADS} \
    --json-conf "${YAML}" \
    --tsv "${BLX}" \
    --orfs "${ORFS}" \
    --transcripts "${FASTA}" \
    --blast_targets "${BLASTFASTA}" \
    --junctions "${JUNC}" \
    "${DB}" \
    > "${LOG_FILE}" 2>&1

echo "Mikado serialise command finished. Check ${LOG_FILE} for details."
