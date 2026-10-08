#!/usr/bin/env python
# extract_supported.py
# Extracts gene models from a GFF3 file that have evidence support (support > 0)
# based on the header comments in the original GFF file.

import sys
import os
import gffutils

# --- Argument Setup ---
# The script expects three arguments:
# 1. Path to the original combined GFF file (for finding support scores)
# 2. Path to the combined GFF3 file (for gene model extraction)
# 3. Path for the output GFF3 file

if len(sys.argv) != 4:
    print("Usage: python extract_supported.py <input_gff> <input_gff3> <output_gff3>", file=sys.stderr)
    sys.exit(1)

input_gff = sys.argv[1]
input_gff3 = sys.argv[2]
fout_name = sys.argv[3]

# Define paths for the gffutils database
db_fn = input_gff3 + ".db"
feature_list = []

print(f"Input GFF (Scores): {input_gff}", file=sys.stderr)
print(f"Input GFF3 (Features): {input_gff3}", file=sys.stderr)
print(f"Output GFF3: {fout_name}", file=sys.stderr)
print(f"GFFutils DB: {db_fn}", file=sys.stderr)

# --- 1. Identify Supported Genes from GFF ---
print("Step 1: Identifying supported genes (support > 0) from GFF...", file=sys.stderr)
try:
    with open(input_gff, 'r') as input_file:
        current_gene = None
        for line in input_file:
            # Match the start gene line to capture the gene ID
            if line.startswith("# start gene"):
                # Example line: # start gene tpl.B1
                try:
                    current_gene = line.split(" ")[3].strip()
                except IndexError:
                    current_gene = None  # Handle badly formatted lines
            
            # Match the support line
            elif line.startswith("# % of transcript"):
                # Example line: # % of transcript supported by hints: 100.00
                try:
                    support = float(line.split(": ")[1])
                    if current_gene and support > 0:
                        feature_list.append(current_gene)
                except (ValueError, IndexError):
                    # Ignore lines that don't parse correctly
                    pass
    print(f"Found {len(feature_list)} supported genes.", file=sys.stderr)
    
except Exception as e:
    print(f"ERROR reading GFF file: {e}", file=sys.stderr)
    sys.exit(1)


# --- 2. Create/Load gffutils Database ---
print("Step 2: Creating/Loading gffutils database...", file=sys.stderr)
try:
    # Attempt to create the DB (if it doesn't exist)
    db = gffutils.create_db(
        input_gff3, 
        db_fn, 
        keep_order=True,
        merge_strategy="create_unique",
        disable_infer_genes=True,
        disable_infer_transcripts=True
    )
except:
    # If creation fails (e.g., DB exists), just load it
    try:
        db = gffutils.FeatureDB(db_fn)
    except Exception as e:
        print(f"ERROR creating or loading gffutils database: {e}", file=sys.stderr)
        sys.exit(1)


# --- 3. Extract Supported Features ---
print("Step 3: Extracting features for supported genes...", file=sys.stderr)
try:
    with open(fout_name,'w') as fout:
        fout.write("##gff-version 3\n")
        
        # Iterate through all 'gene' features
        for gene in db.features_of_type("gene"):
            # Check if the gene is in our list of supported genes
            if gene.id in feature_list:
                # Print the gene and all its children features (mRNA, Exon, CDS, UTRs)
                fout.write(str(gene) + "\n")
                
                # Fetch and print children (isoforms/mRNAs)
                for isoform in db.children(gene, featuretype='mRNA'):
                    fout.write(str(isoform) + "\n")
                    
                    # Fetch and print sub-features, sorted by start position
                    for feature_type in ["exon", "CDS", "five_prime_utr", "three_prime_utr"]:
                        for feature in db.children(isoform, featuretype=feature_type, order_by='start'):
                            fout.write(str(feature) + "\n")
                            
    print("Extraction complete.", file=sys.stderr)

except Exception as e:
    print(f"ERROR during feature extraction: {e}", file=sys.stderr)
    sys.exit(1)

# --- Final Cleanup (Optional: remove temporary DB) ---
# os.remove(db_fn)

sys.exit(0)
