#!/bin/bash
# Description: Creates the EVidenceModeler (EVM) weights file by defining scores for all input evidence sources.
# Requirements: Python 3 must be available.

# --- USER-DEFINED VARIABLES ---
GENOTYPE="GDB_136"

# --- EVM WEIGHT PARAMETERS (from Snakemake params block) ---
AUGUSTUS_WEIGHT=2
AUGSUPP_WEIGHT=10
TSEBRA_WEIGHT=5
HELIXER_WEIGHT=10 # Note: The rule uses OTHER_WEIGHT for HELIXER, which is 10.
PROT_WEIGHT=4
STRINGTIE_WEIGHT=8
OTHER_WEIGHT=10 # Used for Mikado and Helixer (as per rule logic)

# --- FILE PATHS ---
OUTPUT_WEIGHTS="${GENOTYPE}/evm.weights.txt"
LOG_FILE="logs/${GENOTYPE}.write_weights.log"

# --- SETUP ---
mkdir -p logs

echo "--- Starting EVM Weights File Creation for ${GENOTYPE} ---" | tee "$LOG_FILE"
echo "Output will be saved to: $OUTPUT_WEIGHTS" | tee -a "$LOG_FILE"

# --- CORE PYTHON LOGIC (Replicating the Snakemake 'run' block) ---
python3 - "$OUTPUT_WEIGHTS" << EOF
import sys
import os

output_w = sys.argv[1]

# Weights defined in the Bash script (or Snakemake params)
AUGUSTUS_W = os.environ.get('AUGUSTUS_WEIGHT', 2)
AUGSUPP_W = os.environ.get('AUGSUPP_WEIGHT', 10)
TSEBRA_W = os.environ.get('TSEBRA_WEIGHT', 5)
HELIXER_W = os.environ.get('HELIXER_WEIGHT', 10) # Set to 10 by default
PROT_W = os.environ.get('PROT_WEIGHT', 4)
STRINGTIE_W = os.environ.get('STRINGTIE_WEIGHT', 8)
OTHER_W = os.environ.get('OTHER_WEIGHT', 10)

try:
    with open(output_w, "w") as fout:
        # ABINITIO_PREDICTION
        fout.write(f"ABINITIO_PREDICTION\tAugustus\t{AUGUSTUS_W}\n")
        fout.write(f"ABINITIO_PREDICTION\tAUGSUPP\t{AUGSUPP_W}\n")
        fout.write(f"ABINITIO_PREDICTION\tTSEBRA\t{TSEBRA_W}\n")
        
        # PROTEIN
        fout.write(f"PROTEIN\tminiprot_protAln\t{PROT_W}\n")
        
        # TRANSCRIPT
        fout.write(f"TRANSCRIPT\tstringtie\t{STRINGTIE_W}\n")
        
        # OTHER_PREDICTION (Mikado and Helixer)
        fout.write(f"OTHER_PREDICTION\tMikado_loci\t{OTHER_W}\n")
        fout.write(f"OTHER_PREDICTION\tMikado_loci\t{OTHER_W}\n") # Duplicate line in source rule is replicated
        fout.write(f"OTHER_PREDICTION\tHELIXER\t{OTHER_W}\n")
        
except Exception as e:
    print(f"Python script failed: {e}", file=sys.stderr)
    sys.exit(1)
    
print("Python weights script completed successfully.")
EOF
# --- END CORE PYTHON LOGIC ---

EXIT_CODE=$?

# --- FINAL REPORT ---
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "--- SUCCESS: Weights file created ---" | tee -a "$LOG_FILE"
else
    echo "--- ERROR: Weights file creation failed (Exit Code: $EXIT_CODE). ---" | tee -a "$LOG_FILE"
    exit 1
fi

exit $EXIT_CODE
