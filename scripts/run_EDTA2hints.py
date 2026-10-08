#!/usr/bin/env python3
#
# Literal conversion of the Snakemake rule 'EDTA2hints' (Python run block).
# This script converts an input TE file (presumably a GFF/tabular file from EDTA)
# into AUGUSTUS nonexonpart hints (GFF format).
#

import sys
import os
import csv
from datetime import datetime

# --- Configuration: VARIABLES from the Snakemake Rule ---
# 1. Genome identifier
GENOME_ID = "GDB_136"

# 2. Input File (TE: config['EDTA'][wildcards.genome])
INPUT_TE_FILE = f"EDTA/all_TEanno_combined_and_sorted.gff3" 

# 3. Output File (GFF hints: {genome}/hints.EDTA.gff)
OUTPUT_HINTS_FILE = f"hints/hints.EDTA.gff"

# 4. Log File
LOG_FILE = f"logs/{GENOME_ID}.EDTA2hints.log"

# --- Setup ---
os.makedirs("logs", exist_ok=True)
os.makedirs(GENOME_ID, exist_ok=True)
EXIT_CODE = 0

def log_message(message, tee=False):
    """Writes a message to the log file and optionally prints to stderr/stdout."""
    with open(LOG_FILE, 'a') as f:
        f.write(message + '\n')
    if tee:
        # Use stderr for visibility outside of standard output redirection
        print(message, file=sys.stderr)

try:
    log_message("--- Starting EDTA2hints ---", tee=True)
    log_message("Message: Converting " + INPUT_TE_FILE)
    log_message("Start time: " + datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    log_message(f"Input TE File: {INPUT_TE_FILE}")
    log_message(f"Output GFF Hints: {OUTPUT_HINTS_FILE}")

    # Check for required input file
    if not os.path.exists(INPUT_TE_FILE):
        raise FileNotFoundError(f"Input TE file not found at {INPUT_TE_FILE}")

    # =======================================================
    # --- PYTHON RUN BLOCK (LITERAL CONVERSION) ---
    # =======================================================
    print("Processing file. Expected input format is a 9-column tab-separated table.", file=sys.stderr)
    
    with open(OUTPUT_HINTS_FILE, "w") as fout:
        with open(INPUT_TE_FILE, "r") as fdh:
            # The input file is expected to be tab-separated
            reader = csv.reader(fdh, delimiter="\t")
            
            for line in reader:
                # Check if the line has exactly 9 columns
                if len(line) == 9:
                    # Construct the AUGUSTUS hint line (GFF-like format)
                    # Output fields: seqname, source, feature, start, end, score, strand, frame, attribute
                    # Original Python: print(line[0],"RepeatMasker\tnonexonpart",line[3],line[4],"0\t.\t.\tsrc=RM",sep="\t", file = fout)
                    
                    # Ensure start (index 3) and end (index 4) are available and clean
                    seqname = line[0]
                    start = line[3]
                    end = line[4]

                    fout.write(
                        f"{seqname}\tRepeatMasker\tnonexonpart\t{start}\t{end}\t0\t.\t.\tsrc=RM\n"
                    )

    # =======================================================
    log_message("\nEDTA2hints completed successfully.")

except FileNotFoundError as e:
    log_message(f"\nERROR: {e}", tee=True)
    EXIT_CODE = 1
except Exception as e:
    log_message(f"\nFATAL ERROR: {e}", tee=True)
    EXIT_CODE = 1
finally:
    log_message("End time: " + datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    sys.exit(EXIT_CODE)
