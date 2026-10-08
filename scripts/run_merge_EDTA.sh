#!/bin/bash

# Define the pattern matching all input files
INPUT_PATTERN="EDTA/*TEanno.gff3"

# Define the target output file path
OUTPUT_FILE="EDTA/all_TEanno_combined_and_sorted.gff3"

echo "Starting combination and cleanup of ${INPUT_PATTERN}..."

# Use head to get the header from the first file and pipe it to the output
# Then use awk to strip headers from all files before catting them.
{
    # 1. Print the header from the first file found (e.g., chr1H)
    head -n 1000 ${INPUT_PATTERN} | grep '^#' | uniq 
    
    # 2. Concatenate all files and pipe to awk. 
    #    Awk prints all lines that DO NOT start with a '#' (the body of the GFF3).
    #    It also skips blank lines.
    cat ${INPUT_PATTERN} \
    | awk '!/^#|^$/{print}' \
    | sort -k 1,1 -k 4,4n
} > "${OUTPUT_FILE}"

# NOTE: The 'head' approach above assumes a maximum header size.
# A more robust, standard method is to use 'grep -v' for the body:

echo "Combined and cleaned files saved to: ${OUTPUT_FILE}"

# The file now ready to be used as input for the EDTA2hints rule.
