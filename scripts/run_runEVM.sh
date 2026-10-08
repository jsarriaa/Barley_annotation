#!/bin/bash
# run_runEVM.sh
# Executes EVidenceModeler (EVM) using all prepared evidence streams, genome, and weights.

# --- Usage and Setup ---

GENOTYPE="GDB_136"
RUN_ID="run2"
LOGS_DIR="logs"
THREADS=32

# === USER CONFIGURATION: Set the base directory for EVM and Project Root ===
# EVM_BASE_DIR is the root of your annotation environment where EVM-v2.1.0 lives
EVM_BASE_DIR="/scratch/GDB136/new_anno" 
# PROJECT_ROOT is the absolute path to the directory where you are running this script.
PROJECT_ROOT=$(pwd)
# =========================================================

# --- Input Files (Defined with Absolute Paths for Reliability) ---

# All files inside the genotype directory
INPUT_GP="${PROJECT_ROOT}/${GENOTYPE}/evm.abinitio_gene_predictions.gff"
INPUT_PROT="${PROJECT_ROOT}/${GENOTYPE}/evm.uniref_plants_c50.miniprot_aln.gff"
INPUT_STRINGTIE="${PROJECT_ROOT}/${GENOTYPE}/evm.stringtie_transcripts.gff"
INPUT_WEIGHTS="${PROJECT_ROOT}/${GENOTYPE}/evm.weights.txt"

# Genome FASTA (Adjusted path based on your input 'genome/GDB_136.fa')
INPUT_GENOME="${PROJECT_ROOT}/data/${GENOTYPE}.fa"

# Repeats GFF3 (Crucial Fix: Use absolute path for the TE file)
# Assuming it is located at: /scratch/GDB136/annotation/EDTA/all_TEanno_combined_and_sorted.gff3
INPUT_REPEATS="${PROJECT_ROOT}/EDTA/all_TEanno_combined_and_sorted.gff3" 

# --- Tool and Parameters ---

OUTPUT_GFF="${GENOTYPE}/${GENOTYPE}.${RUN_ID}.EVM.gff3"
EVM_TOOL="${EVM_BASE_DIR}/EVidenceModeler-v2.1.0/EVidenceModeler"
CURRENT_LOG="${LOGS_DIR}/${GENOTYPE}.evm.log"

SEGMENT_SIZE=900000
OVERLAP_SIZE=50000
SAMPLE_ID="${GENOTYPE}.${RUN_ID}"

# --- Pre-run Checks ---

EVM_TOOL=$(eval echo "$EVM_TOOL") 
if [ ! -x "$EVM_TOOL" ]; then
    echo "Error: EVidenceModeler tool not found or is not executable at $EVM_TOOL." >&2
    exit 1
fi

CRITICAL_FILES=("$INPUT_GP" "$INPUT_PROT" "$INPUT_STRINGTIE" "$INPUT_WEIGHTS" "$INPUT_GENOME" "$INPUT_REPEATS")
echo "Checking critical input files:"
for file in "${CRITICAL_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "Error: Critical input file missing: $file" >&2
        # Exit with a different code for clarity
        exit 2 
    fi
done

mkdir -p "$LOGS_DIR" "$GENOTYPE"

echo "--- Starting EVidenceModeler (EVM) for Genotype: ${GENOTYPE} ---"
echo "Log: ${CURRENT_LOG}"

# Redirect output to log file
exec &> "$CURRENT_LOG"

# --- Core Execution Step ---

# Change directory into the genotype folder. All EVM output files will be created here.
cd "$GENOTYPE" || { echo "Error: Failed to change directory to $GENOTYPE" ; exit 1; }

echo "1. Running EVidenceModeler with absolute paths..."

# Pass all inputs using their FULL, ABSOLUTE PATHS. 
# This bypasses all issues with relative path resolution by partition_EVM_inputs.pl.
"$EVM_TOOL" \
    --repeats "$INPUT_REPEATS" \
    --sample_id "$SAMPLE_ID" \
    --genome "$INPUT_GENOME" \
    --weights "$INPUT_WEIGHTS" \
    --gene_predictions "$INPUT_GP" \
    --protein_alignments "$INPUT_PROT" \
    --transcript_alignments "$INPUT_STRINGTIE" \
    --CPU "$THREADS" \
    -S \
    --segmentSize "$SEGMENT_SIZE" \
    --overlapSize "$OVERLAP_SIZE"
#    --report_ELM \     # Remove to avoid bugged lines as thomas said

EXIT_CODE=$?

cd '../' # Return to the original working directory

# --- Final Report ---

echo -e "\n--- Pipeline Summary ---"
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "EVidenceModeler execution: SUCCESS"
    echo "EVM GFF saved to: $OUTPUT_GFF"
    echo "Next step is to filter out ELM features."
    exit 0
else
    echo "ERROR: EVidenceModeler failed (Exit Code $EXIT_CODE). Review log for details." >&2
    exit 1
fi
