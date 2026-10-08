#!/bin/bash
# Script to filter Stringtie GTF with Portcullis junctions.

# --- Define File Paths ---
GENOTYPE="GDB_136"

# Input files
MERGED_GTF="stringtie/GDB_136_stringtie.merged.gtf"
JUNCTIONS_BED="portcullis/GDB_136.junctions.bed"

# Output file
OUTPUT_GTF="stringtie/stringtie.merged.junc_flt.gtf"

# Log file
LOG_FILE="logs/${GENOTYPE}.stringtie_flt.log"

# --- Main Script Execution ---

# Redirect all stdout and stderr to the log file.
exec &> "${LOG_FILE}"

# Log the action.
echo "Filtering Stringtie assemblies with Portcullis junctions for genotype: ${GENOTYPE}"

# Run the junctools command exactly as defined in the Snakemake rule.
# The command filters the merged GTF file using the junction coordinates
# from the BED file and outputs a new filtered GTF file.
junctools gtf \
    -j "${JUNCTIONS_BED}" \
    filter \
    "${MERGED_GTF}" \
    -o "${OUTPUT_GTF}"

# Log completion.
echo "Filtering complete. Output file created at ${OUTPUT_GTF}"
