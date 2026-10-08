#!/bin/bash
# Script to merge Stringtie assemblies.

# Define the directory where the Stringtie GTF files are located.
GTF_DIRECTORY="stringtie"

# Define the output file name and path.
# Assuming the genotype is GDB136 and the parent directory is /scratch/GDB136/annotation/
OUTPUT_GTF="stringtie/GDB_136_stringtie.merged.gtf"

LOG_FILE="logs/stringtie_merge.log"
exec &> "${LOG_FILE}"

# Log the action.
echo "Merging Stringtie GTF files from ${GTF_DIRECTORY}..."

find "${GTF_DIRECTORY}" -name "*.gtf" | xargs stringtie --merge -o "${OUTPUT_GTF}"

# Log completion.
echo "Merging complete. Output file created at ${OUTPUT_GTF}"
