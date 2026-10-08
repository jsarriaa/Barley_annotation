#!/bin/bash

# --- Configuration Variables ---
GENOTYPE="GDB_136"
RUN="RUN1"

# --- Input Files ---
CONFIG_YAML="transcripts/${GENOTYPE}.mikado.config.yaml"
INPUT_DB="transcripts/${GENOTYPE}_mikado.db"
INPUT_GTF="transcripts/${GENOTYPE}_mikado_prepared.gtf" # CRITICAL: Required as positional argument

# --- Output Files ---
OUTPUT_LOCI="${GENOTYPE}.mikado_refined_prediction.${RUN}.loci.gff3"
OUTPUT_MONOLOCI="${GENOTYPE}.mikado_refined_prediction.${RUN}.monoloci.gff3"
OUTPUT_DIR="mikado/"

mkdir -p "${OUTPUT_DIR}"

# --- Execution ---

echo "Starting Mikado pick for ${GENOTYPE}..."

mikado pick \
  -p 32 \
  --json-conf ${CONFIG_YAML} \
  -db ${INPUT_DB} \
  --monoloci-out ${OUTPUT_MONOLOCI} \
  --loci-out ${OUTPUT_LOCI} \
  -od ${OUTPUT_DIR} \
  ${INPUT_GTF}

echo "Mikado pick completed."
