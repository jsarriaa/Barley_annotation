#!/bin/bash
# run_write_weights.sh
# Creates the EVidenceModeler (EVM) weights file based on predefined scores for each evidence type.

# --- Usage and Setup ---

GENOTYPE="GDB_136"
LOGS_DIR="logs"

# Output file
OUTPUT_WEIGHTS="${GENOTYPE}/evm.weights.txt"

# Log file
CURRENT_LOG="${LOGS_DIR}/${GENOTYPE}.write_weights.log"

# --- Parameters (EVM Weights) ---
# Weights as defined in the Snakemake rule:
AUGUSTUS_WEIGHT=2
AUGSUPP_WEIGHT=10
TSEBRA_WEIGHT=5
PROT_WEIGHT=4
STRINGTIE_WEIGHT=8
MIKADO_WEIGHT=10 # Labeled as OTHER_PREDICTION in the rule

# --- Pre-run Checks ---

# Ensure log directory exists
mkdir -p "$LOGS_DIR"

echo "--- Starting EVM Weights File Creation for Genotype: ${GENOTYPE} ---"
echo "Log: ${CURRENT_LOG}"

# Redirect all subsequent script output (stdout and stderr) to the main log file
exec &> "$CURRENT_LOG"

# --- Core Execution Step ---

echo "1. Writing weights to ${OUTPUT_WEIGHTS}..."

# Use a Here Document (EOF) to write the content directly to the output file,
# simulating the Python script's 'print' commands.
cat << EOF > "$OUTPUT_WEIGHTS"
ABINITIO_PREDICTION	Augustus	${AUGUSTUS_WEIGHT}
ABINITIO_PREDICTION	AUGSUPP	${AUGSUPP_WEIGHT}
ABINITIO_PREDICTION	TSEBRA	${TSEBRA_WEIGHT}
PROTEIN	miniprot_protAln	${PROT_WEIGHT}
TRANSCRIPT	stringtie	${STRINGTIE_WEIGHT}
OTHER_PREDICTION	Mikado_loci	${MIKADO_WEIGHT}
EOF

EXIT_CODE=$?

# --- Final Report ---

echo -e "\n--- Pipeline Summary ---"
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "Weights file creation: SUCCESS"
    echo "Weights file saved to: $OUTPUT_WEIGHTS"
    echo "Note: The weights define the priority for EVM's consensus prediction."
    exit 0
else
    echo "ERROR: Weights file creation failed (Exit Code $EXIT_CODE). Review log for details." >&2
    exit 1
fi
