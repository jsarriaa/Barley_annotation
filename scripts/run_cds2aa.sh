#!/bin/bash

# This script translates CDS sequences to protein sequences.

# --- USER-DEFINED VARIABLES ---
GENOTYPE="GDB_136"

# --- FILE PATHS AND PARAMETERS ---
# Input file (from the previous step)
INPUT_CDS="transcripts/${GENOTYPE}_mikado_transcripts.loci.cds.fa"

# Output file
OUTPUT_PROT="transcripts/${GENOTYPE}_mikado_transcripts.loci.aa.fa"

# Log file
LOG_FILE="logs/${GENOTYPE}.mikado.transcripts_mik.write_aa.log"

# --- INPUT FILE CHECK ---
echo "Checking for required input file..."

if [ ! -f "$INPUT_CDS" ]; then
    echo "ERROR: CDS FASTA file not found: $INPUT_CDS" >&2
    exit 1
fi

echo "Input CDS file found."

# --- MAIN COMMAND ---
echo "Starting translation of CDS sequences for genotype: ${GENOTYPE}"

# Create the output directory if it doesn't exist
mkdir -p "$(dirname "$OUTPUT_PROT")"

# Execute the embedded Python script and redirect all output to the log file
python3 - <<END_OF_PYTHON_CODE &> "${LOG_FILE}"

# Import necessary libraries
import sys
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord

# Get file paths from the Bash script arguments
input_cds_path = "$INPUT_CDS"
output_prot_path = "$OUTPUT_PROT"

try:
    with open(output_prot_path, "w") as outfile:
        # Loop through each sequence in the input FASTA file
        for record in SeqIO.parse(input_cds_path, "fasta"):
            # Check if the sequence length is a multiple of 3
            if len(record.seq) % 3 == 0:
                # Translate the sequence
                translated_seq = record.seq.translate()
                
                # Create a new record for the protein sequence
                prot_record = SeqRecord(
                    translated_seq, 
                    id=record.id, 
                    description=""
                )
                
                # Write the protein sequence to the output file
                SeqIO.write(prot_record, outfile, "fasta")
    print("Translation completed successfully.")
except Exception as e:
    print(f"An error occurred: {e}", file=sys.stderr)
    sys.exit(1)

END_OF_PYTHON_CODE

echo "Protein translation command finished. Check ${LOG_FILE} for details."
