#!/bin/bash
#
# Literal conversion of the Snakemake rule 'aln2hints_hc'.
# Executes a custom Python script to process 'hc.gff'.

# --- Configuration: VARIABLES from the Snakemake Rule ---
# 1. Genome identifier
GENOME_ID="GDB_136" # Corresponds to {genome}

# 2. Input File
# Note: This file comes from the miniprothints rule output.
INPUT_GFF_FILE="miniprothints/hc.gff" # {input.gff}

# 3. Output File
OUTPUT_GFF_FILE="miniprothints/${GENOME_ID}_uniref_tax38820.hc.hints.gff" # {output.gff}

# 4. Resources and Logging
LOG_FILE="logs/${GENOME_ID}.uniref_plants_c50.aln2hints.log"

# --- Setup ---
mkdir -p logs genome

# Define the path for the transient Python script
PYTHON_SCRIPT="scripts/process_hc_gff.py"

# --- WRITE THE PYTHON SCRIPT ---
# The actual Python logic defined above must be saved to a file.
# Note: This block creates the file 'process_hc_gff.py' in the current directory.
cat << EOT > "${PYTHON_SCRIPT}"
import csv
import sys
import re
from collections import defaultdict

def process_hc_gff(input_gff_path, output_gff_path):
    """
    Groups GFF features by the 'prots' tag and assigns a sequential 'grp=cN' tag.
    This logic replicates the Snakemake 'run:' block for the aln2hints_hc rule.
    """
    d = defaultdict(list)
    
    # --- Reading Input GFF and Grouping ---
    try:
        with open(input_gff_path, "r") as fdh:
            # Using csv.reader for tab-delimited file
            lines = csv.reader(fdh, delimiter="\t")
            
            try:
                # Attempt to read the first line
                first_line = next(lines)
            except StopIteration:
                print(f"Error: Input file {input_gff_path} is empty.", file=sys.stderr)
                return

            # Process the first line as data, then the rest
            current_lines = [first_line] + list(lines)

            for line in current_lines:
                # Skip comment lines or lines that don't look like GFF
                if len(line) < 9 or line[0].startswith('#'):
                    continue

                # Clean up whitespace in attribute column (column 8)
                attributes_str = line[8].replace(" ", "")
                
                # Parse attributes into a dictionary
                tags = {}
                for x in attributes_str.split(";"):
                    if '=' in x:
                        parts = x.split('=', 1)
                        tags[parts[0]] = parts[1]

                # Group lines by the 'prots' tag
                if 'prots' in tags:
                    d[tags['prots']].append(line)

    except FileNotFoundError:
        print(f"Error: Input file {input_gff_path} not found.", file=sys.stderr)
        return

    # --- Writing Output GFF with New Group IDs ---
    grp = 1
    try:
        with open(output_gff_path, "w") as fout:
            for prot_id in d:
                for n in d[prot_id]:
                    # Remove '_codon' from feature type (column 2)
                    n[2] = re.sub('_codon', '', n[2])
                    
                    # Construct the new attribute string for the hints GFF:
                    new_attributes = f"grp=c{grp};src=C;pri=4;"
                    
                    # Print columns 0 through 7, followed by the new attributes
                    print(*n[0:8], new_attributes, sep='\t', file=fout)
                
                # Increment the group counter after processing all features for one protein
                grp += 1
                
    except Exception as e:
        print(f"Error writing to output file {output_gff_path}: {e}", file=sys.stderr)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        # If arguments are missing, exit
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    process_hc_gff(input_file, output_file)

EOT

# --- Execution ---

echo "--- Starting aln2hints_hc (Custom Python Logic) ---" | tee "${LOG_FILE}"
echo "Start time: $(date)" | tee -a "${LOG_FILE}"
echo "Input GFF: ${INPUT_GFF_FILE}" | tee -a "${LOG_FILE}"
echo "Output GFF: ${OUTPUT_GFF_FILE}" | tee -a "${LOG_FILE}"
echo "Command executed: python ${PYTHON_SCRIPT} ${INPUT_GFF_FILE} ${OUTPUT_GFF_FILE}" | tee -a "${LOG_FILE}"

# Check for required input file
if [ ! -f "${INPUT_GFF_FILE}" ]; then
    echo "ERROR: Input GFF file not found at ${INPUT_GFF_FILE}" | tee -a "${LOG_FILE}"
    rm -f "${PYTHON_SCRIPT}" # Clean up temporary script
    exit 1
fi

# Run the Python script
python "${PYTHON_SCRIPT}" "${INPUT_GFF_FILE}" "${OUTPUT_GFF_FILE}" 2>&1 | tee -a "${LOG_FILE}"

PYTHON_EXIT_CODE=$?

# --- Cleanup and Reporting ---
rm -f "${PYTHON_SCRIPT}"

echo "" | tee -a "${LOG_FILE}"
echo "End time: $(date)" | tee -a "${LOG_FILE}"

if [ ${PYTHON_EXIT_CODE} -eq 0 ]; then
    echo "aln2hints_hc processing completed successfully." | tee -a "${LOG_FILE}"
else
    echo "ERROR: aln2hints_hc processing failed with exit code ${PYTHON_EXIT_CODE}." | tee -a "${LOG_FILE}"
fi

exit ${PYTHON_EXIT_CODE}
