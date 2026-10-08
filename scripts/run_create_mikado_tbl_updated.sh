#!/bin/bash

GENOTYPE=GDB_136
RUN=run2

OUT_DIR="sprot_plants_mikado_db"
OUT_FILE="${OUT_DIR}/${GENOTYPE}.mikado.tbl"

# Clear the file content if it exists to start fresh
> "$OUT_FILE"

# --- Write the rows ---
# Format: FilePath \t Label \t Stranded \t Score \t IsRef \t Trim \t Class \t Subloci

# 1. Augustus Supported
printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
    "${GENOTYPE}/augustus.hints.all_combined.supported.gff3" \
    "augsupp" "True" "8" "True" "True" "False" "False" >> "$OUT_FILE"

# 2. EVM (Uses the RUN variable)
printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
    "mikado/${GENOTYPE}.RUN1.EVM.no_ELM.gff3" \
    "evm" "True" "8" "True" "True" "False" "False" >> "$OUT_FILE"

# 3. Mikado Transcripts
printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
    "transcripts/${GENOTYPE}_mikado_transcripts.loci.gff3" \
    "mik" "True" "5" "False" "True" "False" "False" >> "$OUT_FILE"

# 4. Proteins (Miniprot)
printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
    "miniprot/GDB_136.prots.miniprot.gff" \
    "prot" "True" "5" "False" "True" "False" "False" >> "$OUT_FILE"

# 5. Helixer
printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
    "${GENOTYPE}/${GENOTYPE}.helixer.combined.gff3" \
    "helixer" "True" "8" "True" "True" "False" "False" >> "$OUT_FILE"

# Optional: TSEBRA (Commented out as per your snakefile)
printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" \
   "${GENOTYPE}/augustus.hints.all_combined.tsebra.gff3" \
   "TSEBRA" "True" "8" "True" "True" "False" "False" >> "$OUT_FILE"

echo "Success! Table created at: $OUT_FILE"
