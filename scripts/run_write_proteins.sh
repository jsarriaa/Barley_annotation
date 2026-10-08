#!/bin/bash

# --- Configuration Variables ---
GENOTYPE="GDB_136" # Example genotype
RUN="RUN1"         # Example run ID
LOG_DIR="logs"

# --- Input/Output Files ---
INPUT_CDS="${GENOTYPE}/${GENOTYPE}.mikado_refined_prediction.${RUN}.loci.cds.fa"
OUTPUT_PROT="${GENOTYPE}/${GENOTYPE}.mikado_refined_prediction.${RUN}.loci.aa.fa"

# --- Logging Setup ---
LOG_FILE="${LOG_DIR}/${GENOTYPE}.mikado.refined_prediction_mik.write_aa.log"

# Create the logs directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Start log file
echo "--- Starting CDS to Protein Translation for ${GENOTYPE} (Run: ${RUN}) ---" > "$LOG_FILE"
echo "Start Time: $(date)" >> "$LOG_FILE"
echo "------------------------------------------------------------------" >> "$LOG_FILE"

# --- Execution ---

echo "Starting protein translation. Log redirected to ${LOG_FILE}"

# Check if input file exists
if [[ ! -f "$INPUT_CDS" ]]; then
    echo "ERROR: Input CDS file not found: $INPUT_CDS" >> "$LOG_FILE"
    echo "ERROR: Input CDS file not found. Check log file: ${LOG_FILE}"
    exit 1
fi

# Embed the Python script logic to perform translation
python3 - << EOF
import sys
from Bio import SeqIO
from Bio.SeqRecord import SeqRecord

input_cds = "$INPUT_CDS"
output_prot = "$OUTPUT_PROT"
log_file = "$LOG_FILE"

try:
    with open(output_prot, "w") as outfile:
        # Loop through each CDS sequence record
        for record in SeqIO.parse(input_cds, "fasta"):
            # CRITICAL LOGIC: Check if the sequence length is divisible by 3 (complete codons)
            if len(str(record.seq)) % 3 == 0:
                # Translate the sequence
                tmprecord = SeqRecord(record.seq.translate(), id=record.id, description="")
                # Write the translated protein sequence
                SeqIO.write(tmprecord, outfile, "fasta")
            else:
                print(f"Warning: Skipping {record.id}. Length ({len(str(record.seq))}) is not a multiple of 3.", file=sys.stderr)

except Exception as e:
    # Print Python errors to stderr and pipe to log file
    print(f"Python execution failed: {e}", file=sys.stderr)
    sys.exit(1)

EOF

# Capture the exit status of the Python block
EXIT_STATUS=$?

echo "------------------------------------------------------------------" >> "$LOG_FILE"
echo "Finish Time: $(date)" >> "$LOG_FILE"

if [[ $EXIT_STATUS -eq 0 ]]; then
    echo "Protein translation completed successfully." >> "$LOG_FILE"
    echo "Successfully wrote proteins to ${OUTPUT_PROT}"
else
    echo "Protein translation failed with exit code $EXIT_STATUS. Check log file: ${LOG_FILE}" >> "$LOG_FILE"
    echo "Protein translation failed. Check log file: ${LOG_FILE}"
    exit 1
fi
