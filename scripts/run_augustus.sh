#!/bin/bash
# run_all_partition_jobs_parallel.sh

# --- Configuration ---
GENOTYPE="GDB_136"
SPECIES="wheat"
MAX_PARALLEL_JOBS=16  # <-- ADJUST THIS based on available cores on your machine
SKIP_FINISHED=true    # Skip jobs if the .gff output already exists

JOBLIST="${GENOTYPE}/abinitio_jobs.lst"
HINTS_FILE="${GENOTYPE}/hints.all_combined.gff"
EXTRINSIC_CFG="pananno/extrinsic.cfg"
LOGS_DIR="logs"

# Ensure directories exist
mkdir -p "$LOGS_DIR"
mkdir -p "${GENOTYPE}/abinitio"

# Fixed arguments
FIXED_ARGS="--species=$SPECIES --hintsfile=$HINTS_FILE --extrinsicCfgFile=$EXTRINSIC_CFG --alternatives-from-evidence=true --allow_hinted_splicesites=atac"

echo "--- Starting AUGUSTUS Parallel Pipeline ---"
echo "Jobs to process: $(grep -c "^augustus" $JOBLIST)"
echo "Parallel workers: $MAX_PARALLEL_JOBS"

# Function to run a single job (used for parallelization)
run_augustus_job() {
    local cmd="$1"
    local fixed_args="$2"
    local logs_dir="$3"
    local genotype="$4"
    local skip_finished="$5"

    # Extract output path
    local outfile=$(echo "$cmd" | grep -oP '(--outfile=)\K[^ ]+')
    local job_id=$(basename "$outfile" .gff)
    local current_log="${logs_dir}/${genotype}.augustus.${job_id}.log"

    # Skip if already done
    if [ "$skip_finished" = true ] && [ -f "$outfile" ] && [ -s "$outfile" ]; then
        return 0
    fi

    # Construct and execute
    local full_command="augustus ${fixed_args} ${cmd#augustus}"
    eval "$full_command" > "$current_log" 2>&1

    if [ $? -eq 0 ]; then
        echo "[OK] $job_id"
    else
        echo "[FAIL] $job_id - check $current_log"
    fi
}

export -f run_augustus_job # Export function so subshells can see it

# --- Main Loop ---
JOB_COUNT=0
while IFS= read -r job_command; do
    if [[ "$job_command" =~ ^augustus ]]; then
        
        # Run job in background
        run_augustus_job "$job_command" "$FIXED_ARGS" "$LOGS_DIR" "$GENOTYPE" "$SKIP_FINISHED" &
        
        JOB_COUNT=$((JOB_COUNT + 1))

        # --- Parallel Control ---
        # This part ensures we don't start more than MAX_PARALLEL_JOBS at once
        if [[ $(jobs -r -p | wc -l) -ge $MAX_PARALLEL_JOBS ]]; then
            wait -n  # Wait for at least one background job to finish
        fi
    fi
done < "$JOBLIST"

# Final wait for the last batch to finish
wait
echo -e "\n--- Finished! All launched jobs have completed. ---"
