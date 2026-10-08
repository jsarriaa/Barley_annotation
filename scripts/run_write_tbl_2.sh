#!/bin/bash

# --- Configuration Variables (Replace these with actual values) ---
# Snakemake variables: RUN and genotype
GENOTYPE="GDB_136"  # Example: Replace with your actual genotype
RUN="run2"          # Example: Replace with your actual run name

# Define the paths for all input files (using the variables above)
INPUT_AUGSUP="${GENOTYPE}/augustus.hints.all_combined.supported.gff3"
INPUT_EVM="${GENOTYPE}/${GENOTYPE}.${RUN}.EVM.no_ELM.gff3"
INPUT_MIK="${GENOTYPE}/mikado_transcripts.loci.gff3"
INPUT_PROT="${GENOTYPE}/${GENOTYPE}.uniref_plants_c50.miniprot.gff"
INPUT_HELIXER="${GENOTYPE}/${GENOTYPE}.helixer.combined.gff3"
# Note: TSEBRA is commented out in the Snakemake rule, so it's not included in the output logic.

# Define the Output file path
OUTPUT_TBL="${GENOTYPE}/refine_prediction/${GENOTYPE}.mikado.tbl"

# Define Log files (optional, as the core logic is not a shell command)
LOG_FILE="logs/${GENOTYPE}.refine_prediction_mik.write_tbl.log"
LOG_E="logs/${GENOTYPE}.refine_prediction_mik.write_tbl.log.e"
LOG_O="logs/${GENOTYPE}.refine_prediction_mik.write_tbl.log.o"

# Ensure the output directory exists
mkdir -p "${GENOTYPE}/refine_prediction"
mkdir -p logs

# --- Core Operation: Equivalent to the Snakemake 'run' block ---
echo "Writing input table file: ${OUTPUT_TBL}" | tee -a "$LOG_FILE"

# The command below uses 'echo -e' to allow for tab expansion (\t) 
# and redirects all output using '>' to create/overwrite the output file.

# Start the file redirection
{
    # print(input.augsup,"augsupp","True","8","True","True","False","False",sep='\t',file=fout)
    echo -e "${INPUT_AUGSUP}\taugsupp\tTrue\t8\tTrue\tTrue\tFalse\tFalse"
    
    # print(input.evm,"evm","True","8","True","True","False","False",sep='\t',file=fout)
    echo -e "${INPUT_EVM}\tevm\tTrue\t8\tTrue\tTrue\tFalse\tFalse"
    
    # print(input.mik,"mik","True","5","False","True","False","False",sep='\t',file=fout)
    echo -e "${INPUT_MIK}\tmik\tTrue\t5\tFalse\tTrue\tFalse\tFalse"
    
    # print(input.prot,"prot","True","5","False","True","False","False",sep='\t',file=fout)
    echo -e "${INPUT_PROT}\tprot\tTrue\t5\tFalse\tTrue\tFalse\tFalse"
    
    # print(input.helixer,"helixer","True","8","True","True","False","False",sep='\t',file=fout)
    echo -e "${INPUT_HELIXER}\thelixer\tTrue\t8\tTrue\tTrue\tFalse\tFalse"
} > "$OUTPUT_TBL" 2> "$LOG_E"

# Check the exit status of the compound command
if [ $? -eq 0 ]; then
    echo "SUCCESS: Input table file written successfully." | tee -a "$LOG_FILE"
else
    echo "ERROR: Could not write the input table file." | tee -a "$LOG_FILE"
    exit 1
fi

exit 0
