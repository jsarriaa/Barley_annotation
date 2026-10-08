#!/bin/bash
#
# Equivalent to hint snakemake script

# --- Configuration: VARIABLES from the Snakemake Rule ---
# 1. Genome identifier
GENOME_ID="GDB_136"

# 2. Input Files
MPI_INDEX_FILE="miniprot/${GENOME_ID}.mpi"
PROTEIN_FASTA_FILE="data/uniref_tax38820_id0.5.fasta"

# 3. Output File
OUTPUT_ALN_FILE="miniprot/${GENOME_ID}.uniref_tax38820_id0.5.miniprot.aln"

# 4. Resources
THREADS=32

# 5. Log File
LOG_FILE="logs/${GENOME_ID}.tax38820_id0.5_hints.log"

echo "--- Starting Miniprot Alignment (Direct Execution) ---" | tee "${LOG_FILE}"
echo "Start time: $(date)" | tee -a "${LOG_FILE}"
echo "Command executed: miniprot -I -u --outn=1 --aln -t ${THREADS} ${MPI_INDEX_FILE} ${PROTEIN_FASTA_FILE} > ${OUTPUT_ALN_FILE}" | tee -a "${LOG_FILE}"

# --- MINIPROT COMMAND (LITERAL SHELL BLOCK CONVERSION) ---
# The command is wrapped to redirect both standard output (the alignment)
# and standard error (Miniprot messages like the index load/stat) to the
# appropriate destinations.

(
    # Miniprot command:
    miniprot \
        -I \
        -u \
        --outn=1 \
        --aln \
        -t "${THREADS}" \
        "${MPI_INDEX_FILE}" \
        "${PROTEIN_FASTA_FILE}" \
        > "${OUTPUT_ALN_FILE}"

) 2>&1 | tee -a "${LOG_FILE}"

MINIPROT_EXIT_CODE=$?

echo "" | tee -a "${LOG_FILE}"
echo "End time: $(date)" | tee -a "${LOG_FILE}"

if [ ${MINIPROT_EXIT_CODE} -eq 0 ]; then
    echo "Miniprot alignment completed successfully." | tee -a "${LOG_FILE}"
else
    echo "ERROR: Miniprot alignment failed with exit code ${MINIPROT_EXIT_CODE}." | tee -a "${LOG_FILE}"
    # NOTE: If the process runs out of memory, this is the exit path.
fi

exit ${MINIPROT_EXIT_CODE}
