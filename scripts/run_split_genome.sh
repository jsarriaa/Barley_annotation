#!/bin/bash
# Description: Replicates the Snakemake 'split_genome' checkpoint rule
# by splitting a reference genome FASTA file into large chromosome chunks
# and a combined contigs file based on length.
# Requires: Python 3 and Biopython (e.g., in a 'mikado_env')

# --- USER-DEFINED VARIABLES (Set your genotype here) ---
GENOTYPE="GDB_136"

# --- FILE PATHS AND PARAMETERS ---
INPUT_GENOME="data/${GENOTYPE}.fa"
LENGTH_FILE="${GENOTYPE}/${GENOTYPE}.lengths"
CHUNKS_DIR="${GENOTYPE}/genome_chunks"
CONTIGS_FILE="${CHUNKS_DIR}/contigs.fa"
MIN_LENGTH=500001 # 500,001 bp threshold for large chunks

LOG_FILE="logs/${GENOTYPE}.split_genome.log"

# --- SETUP AND INPUT CHECK ---
mkdir -p "$CHUNKS_DIR" logs

if [ ! -f "$INPUT_GENOME" ]; then
    echo "ERROR: Genome FASTA not found: $INPUT_GENOME" | tee -a "$LOG_FILE"
    exit 1
fi

echo "--- Starting Genome Splitting for ${GENOTYPE} ---" | tee "$LOG_FILE"
echo "Input: ${INPUT_GENOME}" | tee -a "$LOG_FILE"
echo "Large sequences (>= ${MIN_LENGTH} bp) go to individual files in ${CHUNKS_DIR}/" | tee -a "$LOG_FILE"
echo "Small sequences (< ${MIN_LENGTH} bp) go to ${CONTIGS_FILE}" | tee -a "$LOG_FILE"

# Ensure output files are clean for a fresh run
rm -f "$LENGTH_FILE" "$CONTIGS_FILE"
# Note: Existing individual chunk files are overwritten by the script

# --- CORE PYTHON LOGIC (Replicating the Snakemake 'run' block) ---
python3 - "$INPUT_GENOME" "$LENGTH_FILE" "$CONTIGS_FILE" "$CHUNKS_DIR" "$MIN_LENGTH" << EOF
import sys
from Bio import SeqIO
import os

# Arguments passed from Bash
input_genome = sys.argv[1]
length_file = sys.argv[2]
contigs_file = sys.argv[3]
chunks_dir = sys.argv[4]
min_length = int(sys.argv[5])

# Ensure chunks_dir exists (though Bash already did this)
os.makedirs(chunks_dir, exist_ok=True)

try:
    with open(length_file, "w") as length_f:
        # Use 'a' for contigs to ensure if the script runs multiple times, it appends safely
        # However, for a clean run, we rely on the Bash 'rm -f' above.
        with open(contigs_file, "w") as contigs_f:
            for current_seq in SeqIO.parse(input_genome, "fasta"):
                seq_id = current_seq.id
                seq_length = len(current_seq.seq)
                
                # Check if sequence is large enough for its own file (>= 500001)
                if seq_length >= min_length:
                    # Write to individual FASTA file
                    chunk_path = os.path.join(chunks_dir, f"{seq_id}.fa")
                    with open(chunk_path, "w") as out_f:
                        out_f.write(f">{seq_id}\n{str(current_seq.seq)}\n")
                    
                    # Write metadata to length file
                    length_f.write(f"{chunk_path}\t1\t{seq_length}\n")
                    
                else:
                    # Write to combined contigs FASTA
                    contigs_f.write(f">{seq_id}\n{str(current_seq.seq)}\n")

except Exception as e:
    print(f"Python script failed: {e}", file=sys.stderr)
    sys.exit(1)
    
print("Python split logic completed.")
EOF
# --- END CORE PYTHON LOGIC ---

if [ $? -eq 0 ]; then
    echo "--- SUCCESS: Genome splitting completed ---" | tee -a "$LOG_FILE"
else
    echo "--- ERROR: Genome splitting failed ---" | tee -a "$LOG_FILE"
fi
exit $?
