#!/bin/bash
# run_write_tbl.sh
# Creates the Mikado input table (TSV) which lists all evidence sources 
# and assigns them weights/priorities. This is the first step of the refinement phase.

# --- Configuration ---
GENOTYPE="GDB_136"
RUN="run2"
# The output directory needs to be created, as Mikado will put its output there.
OUTPUT_DIR="${GENOTYPE}/refine_prediction"

# --- Input Files (Defining paths based on the pipeline structure) ---

# TSEBRA-combined Augustus GFF3
INPUT_TSEBRA="${GENOTYPE}/augustus.hints.all_combined.tsebra.gff3"
# Filtered EVM GFF3 from the last step
INPUT_EVM="${GENOTYPE}/${GENOTYPE}.${RUN}.EVM.no_ELM.gff3"
# Mikado-selected transcripts (likely from a previous/separate Mikado run, or a placeholder)
INPUT_MIK="transcripts/${GENOTYPE}_mikado_transcripts.loci.gff3"
# Protein-to-genome alignments GFF3
INPUT_PROT="genome/${GENOTYPE}_uniref_plants_c50.miniprot.gff"

# The final output file name
OUTPUT_TBL="${OUTPUT_DIR}/${GENOTYPE}.mikado.tbl"

# --- Pre-run Checks and Setup ---

# Ensure the output directory exists
mkdir -p "$OUTPUT_DIR"
# Ensure the logs directory exists (though the log isn't used to capture the output here)
mkdir -p logs

# --- Core Execution Step: Generating the Mikado Table ---

echo "--- Generating Mikado Input Table: $OUTPUT_TBL ---"

# The file contents are generated line-by-line using the Python print statements
# and standard shell redirection (> to create, then >> to append).
# Format: path,tag,is_prediction,score_weight,is_gff3,accept_on_match,ignore_multi_exons,has_unannotated_5prime

# Line 1: TSEBRA (Augustus consensus) - Priority 8, Trusted prediction
echo -e "${INPUT_TSEBRA}\tTSEBRA\tTrue\t8\tTrue\tTrue\tFalse\tFalse" > "$OUTPUT_TBL"

# Line 2: EVM (The model you just created) - Highest Priority 10, Trusted prediction
echo -e "${INPUT_EVM}\tevm\tTrue\t10\tTrue\tTrue\tFalse\tFalse" >> "$OUTPUT_TBL"

# Line 3: Mikado (Likely a previous, less-refined run or a placeholder) - Priority 8
echo -e "${INPUT_MIK}\tmik\tTrue\t8\tFalse\tTrue\tFalse\tFalse" >> "$OUTPUT_TBL"

# Line 4: Protein Alignments (Protein homology evidence) - Priority 5, Not a prediction
echo -e "${INPUT_PROT}\tprot\tTrue\t5\tFalse\tTrue\tFalse\tFalse" >> "$OUTPUT_TBL"

echo "Mikado input table generated successfully."
# Display the contents of the generated table for confirmation
cat "$OUTPUT_TBL"
