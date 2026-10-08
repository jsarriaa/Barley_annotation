#!/bin/bash
# Description: Reads the Coding Sequence (CDS) FASTA and translates sequences
# into protein (amino acid) sequences, ensuring only sequences with lengths
# divisible by 3 (complete codons) are processed.
# Requirements: Python 3 and Biopython must be available.

# --- USER-DEFINED VARIABLES ---
GENOTYPE="GDB_136"

# --- FILE PATHS ---
# Input: Combined CDS FASTA file
INPUT_CDS="${GENOTYPE}/${GENOTYPE}.helixer.combined.cds.fa" 
# Output: Combined Protein (AA) FASTA file
OUTPUT_PROT="${GENOTYPE}/${GENOTYPE}.helixer.combined.aa.fa" 

LOG_FILE="logs/${GENOTYPE}.helixer.write_aa.log"

# --- SETUP AND INPUT CHECK ---
mkdir -p logs

if [ ! -f "$INPUT_CDS" ]; then
    echo "ERROR: Input CDS file not found: $INPUT_CDS" | tee "$LOG_FILE"
    exit 1
fi

echo "--- Starting Protein Translation for ${GENOTYPE} ---" | tee "$LOG_FILE"
echo "Input CDS: $INPUT_CDS" | tee -a "$LOG_FILE"
echo "Output Protein: $OUTPUT_PROT" | tee -a "$LOG_FILE"

# --- CORE PYTHON LOGIC (Replicating the Snakemake 'run' block) ---
python3 - "$INPUT_CDS" "$OUTPUT_PROT" << EOF
import sys
import os
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.SeqRecord import SeqRecord

# Arguments passed from Bash
input_cds = sys.argv[1]
output_prot = sys.argv[2]
log_file = os.environ.get('LOG_FILE', '/dev/stderr') # Use environment variable for logging

def log(message):
    with open(log_file, 'a') as f:
        f.write(f"Python script: {message}\n")

try:
    processed_count = 0
    skipped_count = 0
    
    with open(output_prot, "w") as outfile:
        # Loop through all CDS records
        for record in SeqIO.parse(input_cds, "fasta"):
            seq_length = len(str(record.seq))
            
            # Check for length divisible by 3 (complete codons)
            if seq_length % 3 == 0:
                # Translate the sequence
                # .translate() handles stop codons (*) automatically
                tmprecord = SeqRecord(record.seq.translate(), id=record.id, description="")
                SeqIO.write(tmprecord, outfile, "fasta")
                processed_count += 1
            else:
                skipped_count += 1
                log(f"Skipped {record.id}: length ({seq_length}) not divisible by 3.")

    log(f"Translation complete. Processed {processed_count} sequences. Skipped {skipped_count} invalid sequences.")
    
except Exception as e:
    log(f"Python script failed during translation: {e}")
    sys.exit(1)
    
log("Python translation logic completed successfully.")
EOF
# --- END CORE PYTHON LOGIC ---

EXIT_CODE=$?

# --- FINAL REPORT ---
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "--- SUCCESS: Protein translation completed ---" | tee -a "$LOG_FILE"
else
    echo "--- ERROR: Protein translation failed (Exit Code: $EXIT_CODE). ---" | tee -a "$LOG_FILE"
    exit 1
fi
