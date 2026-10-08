#!/bin/bash
#
# Bash script to replicate Snakemake rules 'split_genome' and 'abinitio_joblist'.
# FIXED to use ONLY the base sequence ID (e.g., 'chr1H') for the filename and header.
# Output format explicitly uses a newline after the header.

# --- Configuration ---
GENOTYPE="GDB_136"
GENOME_FASTA="data/${GENOTYPE}.fa"
OUTPUT_DIR="${GENOTYPE}"

# Parameters for splitting
MIN_CHUNK_SIZE=500001               # Sequences >= 500kb are split into chunks
CHUNK_SIZE=500000                   # Chunk size for createAugustusJoblist.pl
OVERLAP_SIZE=50000                  # Overlap size for createAugustusJoblist.pl
JOBS_DIR="${GENOTYPE}/abinitio"     # Directory for Augustus job output
FASTA_WRAP_LENGTH=80                # Standard FASTA wrapping length

# Output Files
LENGTHS_FILE="${OUTPUT_DIR}/${GENOTYPE}.lengths"
CONTIGS_FASTA="${OUTPUT_DIR}/genome_chunks/contigs.fa"
JOBLIST_FILE="${OUTPUT_DIR}/abinitio_jobs.lst"
# --- End Configuration ---

# --- Setup Directories ---
echo "Setting up directories for ${GENOTYPE}..."
mkdir -p "${OUTPUT_DIR}/genome_chunks"
mkdir -p "${JOBS_DIR}"
mkdir -p logs

# Clean up previous runs of the main output files
rm -f "${LENGTHS_FILE}" "${CONTIGS_FASTA}" "${JOBLIST_FILE}"
touch "${CONTIGS_FASTA}" # Ensure the contigs file exists even if empty

# =======================================================
# --- Rule: split_genome (FASTA Parsing and Splitting) ---
# AWK uses a function to ensure consistent output formatting.
# =======================================================
echo "--- Running split_genome ---"

# Awk script logic:
# - Header and sequence data are passed to process_record
# - process_record outputs: ">base_id\nsequence_data"
awk -v GENO="${GENOTYPE}" -v MIN_LEN="${MIN_CHUNK_SIZE}" \
    -v LENGTHS_OUT="${LENGTHS_FILE}" -v CONTIGS_OUT="${CONTIGS_FASTA}" \
    -v WRAP_LEN="${FASTA_WRAP_LENGTH}" '
    
    # Function to process the current record and print to file/stdout
    function process_record(seq_id, seq_data) {
        if (seq_id == "") return # Skip if no ID
        
        # Clean the sequence (remove spaces/newlines)
        gsub(/ |\r|\t/, "", seq_data)
        len = length(seq_data)
        
        # Extract the base ID (part before the first space)
        split(seq_id, parts, " ")
        base_id = parts[1]
        
        # Determine the output stream
        if (len >= MIN_LEN) {
            # Long sequence: individual file and .lengths entry
            fasta_path = GENO "/genome_chunks/" base_id ".fa"
            
            # Print to FASTA file (Header, Newline, Sequence)
            # We print header and sequence to a temporary file, then use fold to wrap it
            print ">" base_id "\n" seq_data > (fasta_path ".tmp")
            
            # Write to .lengths file (path, 1, length)
            print fasta_path "\t1\t" len >> LENGTHS_OUT
            
        } else {
            # Short sequence: append to contigs.fa
            # Print only base_id as the header for the contigs file
            print ">" base_id "\n" seq_data >> (CONTIGS_OUT ".tmp")
        }
    }
    
    # Process each line
    /^>/ {
        # Process the previous record before starting a new one
        if (seq_id != "") {
            process_record(seq_id, seq_data)
        }
        
        # Start a new record
        seq_id = substr($0, 2)
        seq_data = ""
        # Remove trailing carriage returns
        sub(/\r$/, "", seq_id)
        next
    }
    
    # Append sequence data
    {
        seq_data = seq_data $0
    }
    
    # Process the last record in the END block
    END {
        process_record(seq_id, seq_data)
    }
' "${GENOME_FASTA}"

if [ $? -ne 0 ]; then
    echo "ERROR: split_genome failed during FASTA parsing."
    rm -f "${OUTPUT_DIR}"/genome_chunks/*.fa.tmp # Cleanup temp files
    exit 1
fi

# =======================================================
# --- Post-AWK step: Line Wrapping (using fold) ---
# Apply fold to all generated temp files to create final FASTA files
# =======================================================
echo "Applying FASTA line wrapping (width: ${FASTA_WRAP_LENGTH})..."

# Process long sequences
for tmp_file in "${OUTPUT_DIR}"/genome_chunks/*.fa.tmp; do
    if [ -f "$tmp_file" ]; then
        final_file="${tmp_file%.tmp}"
        # fold -w <width> : wrap to a specific width
        # -s : break at spaces (optional, but good practice; might not matter if sequence is clean)
        # We only use -w as the sequence is a single line without spaces
        awk '/^>/ {print $0; next} {gsub(/[^A-Za-z]/, ""); print $0}' "$tmp_file" | fold -w "${FASTA_WRAP_LENGTH}" > "$final_file"
        rm "$tmp_file"
    fi
done

# Process contigs file
if [ -f "${CONTIGS_FASTA}.tmp" ]; then
    awk '/^>/ {print $0; next} {gsub(/[^A-Za-z]/, ""); print $0}' "${CONTIGS_FASTA}.tmp" | fold -w "${FASTA_WRAP_LENGTH}" >> "${CONTIGS_FASTA}"
    rm "${CONTIGS_FASTA}.tmp"
fi

# =======================================================
# --- Checkpoint: abinitio_joblist (Job List Creation) ---
# =======================================================
echo "--- Running abinitio_joblist ---"

if [ ! -f "${LENGTHS_FILE}" ]; then
    echo "ERROR: Input lengths file not found: ${LENGTHS_FILE}"
    exit 1
fi

# The shell command from the checkpoint rule
Augustus/scripts/createAugustusJoblist.pl \
    --sequences "${LENGTHS_FILE}" \
    --outputdir "${JOBS_DIR}" \
    --command "augustus " \
    --joblist "${JOBLIST_FILE}" \
    --chunksize="${CHUNK_SIZE}" \
    --overlap="${OVERLAP_SIZE}"

if [ $? -eq 0 ]; then
    echo "SUCCESS: AUGUSTUS job list created at ${JOBLIST_FILE}"
else
    echo "ERROR: createAugustusJoblist.pl failed."
    exit 1
fi
