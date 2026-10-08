# GDB_136 Genome Annotation Pipeline

## Overview

This repository contains the complete de novo annotation pipeline for *Hordeum vulgare* subsp. *vulgare* GDB_136, a barley landrace originating from Iraq. The annotation was generated following the same protocols and methodologies as the recent Barley Pangenome v2 [(Nature 2024)](https://www.nature.com/articles/s41586-024-08187-1), in close collaboration with the sequencing and assembly teams at [IPK Gatersleben](https://www.ipk-gatersleben.de/).

The pipeline integrates multiple lines of evidence including RNA-seq transcriptomics, long-read RNA sequencing (Iso-Seq), and protein homology information to produce a comprehensive and high-quality gene annotation. The approach is based on the PanAnno pantranscriptome methodology developed at PGSB-HMGU.

### Key Features

- **Multi-evidence integration**: Combines evidence from five tissues (3 replicates each) of mRNA-seq with Iso-Seq from root and shoot tissue pools
- **Comprehensive gene prediction**: Integrates *ab initio* prediction (AUGUSTUS), RNA-seq-based assembly (StringTie), long-read RNA mapping, and protein homology
- **Transposable element annotation**: Full EDTA-based TE annotation pipeline
- **Quality assessment**: BUSCO evaluation and confidence scoring of gene models
- **Publication-ready outputs**: High, medium, and low-confidence gene sets with standardized annotations

### Annotation Statistics

- **Total gene models**: 74,929 genes
- **Protein-coding sequences**: 75,461 transcripts
- **High-confidence set (≥90%)**: 47,701 genes with BUSCO C:91.8%
- **Final PASA-refined set**: BUSCO score C:98.6%[S:65.2%,D:33.4%],F:0.4%,M:0.9%

---

## 1. Data Requirements and Preparation

### 1.1 Required Inputs

Organize all input data in the following structure before starting:

```bash
data/
├── GDB_136.fa                           # Genome assembly (FASTA format)
├── IsoSeq.bam                           # Iso-Seq CCS reads (BAM format)
├── Unknown_CP851-001U0001_good_1.fq.gz # mRNA-seq paired reads (library 1, R1)
├── Unknown_CP851-001U0001_good_2.fq.gz # mRNA-seq paired reads (library 1, R2)
└── ... up to Unknown_CP851-001U0015_good_2.fq.gz  # Total: 15 paired libraries
```

**Input Specifications**:
- **Genome**: High-quality reference assembly with pseudomolecules and unplaced contigs (≈5.5 Gbp for barley)
- **RNA-seq**: 15 paired-end Illumina libraries from 5 tissues (3 replicates each), quality-filtered
- **Iso-Seq**: Circular Consensus Sequences (CCS) in BAM format (≥5.6 million reads)
- **Reference proteins**: Optional, required for Mikado refinement (UniRef50 or SwissProt Plant databases)

### 1.2 Output Files

The pipeline generates:

1. **Primary Annotation**: `GDB136_pasa_db.gene_structures_post_PASA_updates.final.gff3`
   - 74,929 gene models with alternative isoforms
   - BUSCO score: 98.6%

2. **Protein Sequences**: 
   - High confidence (HC, ≥90%): 47,701 proteins
   - Medium confidence (≥80%): 53,416 proteins
   - All models: 58,771+ proteins

3. **Supporting Files**: CDS sequences, functional annotations, TE library

---

## 2. Environment Setup

The pipeline requires multiple conda environments. Create them sequentially:

```bash
# Main annotation environment
conda env create -f scripts/environment.yml
conda activate pananno_jsarria

# TE annotation (EDTA)
conda create -n EDTA_env -c conda-forge -c bioconda edta=2.2.2 -y

# Structural refinement with Mikado
conda create --name mikado_env -c bioconda -c conda-forge python=3.10 mikado=2.3.4 sqlalchemy=1.4.41

# Final PASA refinement
conda create -n pasa_env -c bioconda -c conda-forge \
    pasa mysql-server mysql-client isoseq3 samtools perl-dbd-mysql

# Deep learning gene prediction (Helixer)
conda create -n helixer -c bioconda -c conda-forge python=3.10 helixer-gpu
# Alternative (CPU version): conda create -n helixer -c bioconda -c conda-forge python=3.10 helixer

# Functional annotation post-processing (COCLA)
# See Section 5 for InterProScan and prot-scriber installation
```

---

## 3. Pipeline Execution

### 3.1 Mandatory Data Preparation

Before running the main pipeline, prepare all input files and indices:

#### 3.1.1 Split Genome by Pseudochromosomes and Contigs

```bash
mkdir -p genome_by_contigs
cd genome_by_contigs
awk '/^>/{s=substr($1,2); close(f); f=s".fasta"} {print > f}' ../data/GDB_136.fa
cd ..
```

This creates individual FASTA files for each chromosome/contig, required by partition-based tools (EDTA, Helixer).

#### 3.1.2 Convert IsoSeq BAM to FASTA

```bash
conda activate pananno_jsarria
samtools fasta data/IsoSeq.bam > data/IsoSeq.fa
# Expected: ~5.67 million sequences processed
```

#### 3.1.3 Prepare mRNA-seq Data

Process raw RNA-seq reads through quality filtering and convert to FASTA:

```bash
cd data/
bash ../scripts/process_rnaseq.sh
# Generates: combined_mrna_transcripts.fa (~1.67 billion sequences)
cd ..
```

#### 3.1.4 Build Reference Indices

```bash
bash scripts/run_indexfasta.sh          # SAMtools index for genome
bash scripts/run_minimap2_index.sh      # minimap2 index for Iso-Seq mapping
bash scripts/run_miniprot.sh            # Generate miniprot index for protein alignment
bash scripts/run_split_genome.sh        # Create genome chunks for Helixer processing
```

---

### 3.2 Step 1: Transposable Element Annotation (EDTA)

Transposable element annotation is mandatory and must complete before the main prediction pipeline.

```bash
conda activate EDTA_env

# Run full EDTA pipeline (can take 1-4 weeks for barley genome)
nohup bash scripts/run_edta.sh > logs/EDTA/run_edta.log 2>&1 &

# Convert TE annotation to evidence hints
bash scripts/run_merge_EDTA.sh
python3 scripts/run_EDTA2hints.py
```

**Note**: If `ltr_finder` throws "Illegal instruction" error, compile from source:
```bash
git clone https://github.com/xzhub/LTR_Finder.git
cd LTR_Finder/source && make && cp ltr_finder $CONDA_PREFIX/bin/ && cd ../.. && rm -rf LTR_Finder
```

---

### 3.3 Step 2: Build Evidence (RNA-seq, Iso-Seq, Protein)

#### 3.3.1 RNA-seq Mapping and Transcript Assembly

```bash
conda activate pananno_jsarria

# STAR indexing and mapping
bash scripts/run_STAR.sh
bash scripts/run_STAR_mapping.sh
bash scripts/run_merge_STAR_bams.sh

# Junction filtering and quality control
bash scripts/run_portcullis_prep.sh
bash scripts/run_portcullis_junc.sh
bash scripts/run_portcullis_filter.sh

# StringTie transcript assembly and merging
bash scripts/run_stringtie.sh
bash scripts/run_merge_stringtie.sh

# Filter GTF based on junction confidence
bash scripts/run_juntools_filter.sh
```

#### 3.3.2 Iso-Seq Mapping and Evidence Generation

```bash
# Build minimap2 index
minimap2 -d minimap2_index/GDB_136.mmi data/GDB_136.fa

# Map Iso-Seq to genome with splice-aware alignment
bash scripts/run_Isoseq_minimap2.sh

# Convert alignments to GFF format
bash scripts/run_bam2gff.sh
```

#### 3.3.3 Protein Evidence (miniprot and miniprothint)

```bash
# Run miniprot alignment against reference proteins
bash scripts/run_hints_miniprot.sh
bash scripts/run_score_miniprot.sh
bash scripts/run_hints_miniprot_2.sh

# Generate hints from protein alignments
bash scripts/run_aln2hints_hc.sh
bash scripts/run_join_prothints.sh
```

#### 3.3.4 Combine RNA-seq Hints

```bash
# Process RNA-seq alignments
bash scripts/run_sortBambyreads.sh
bash scripts/run_filterbam.sh
bash scripts/run_sort_flt_bam.sh
bash scripts/run_bam2hints.sh
bash scripts/run_filterIntronsFindStrand.sh
bash scripts/run_wig2hints.sh
bash scripts/run_blat2hints.sh

# Merge all hint files
bash scripts/run_merge_extrinsic_hints.sh
bash scripts/run_combine_all_hints.sh
```

---

### 3.4 Step 3: Generate Gene Predictions

#### 3.4.1 *Ab initio* Prediction with AUGUSTUS

```bash
bash scripts/abinitio_setup.sh

# Run AUGUSTUS with merged evidence hints
nohup bash scripts/run_augustus.sh > logs/augustus_progress.log 2>&1 &

# Monitor progress:
# TOTAL=9252; DONE=$(find new_anno/GDB_136/abinitio/ -name "*.gff" -type f -not -empty | wc -l); PERC=$(awk "BEGIN {printf \"%.2f\", $DONE*100/$TOTAL}"); echo "Progress: $DONE / $TOTAL ($PERC%)"

# Combine chromosome predictions
bash scripts/run_combine_augustus.sh
bash scripts/run_extract_supported.sh
```

#### 3.4.2 TSEBRA Gene Selection

```bash
# Run TSEBRA for consensus gene set
bash scripts/run_tsebra.sh
bash scripts/run_tsebra2gff3.sh
bash scripts/run_tsebra_selection.sh
```

#### 3.4.3 Helixer Deep Learning Predictions

```bash
conda activate helixer
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH

# Download pre-trained plant model
# wget https://zenodo.org/records/10836346/files/land_plant_v0.3_m_0100.h5 -O land_plant_v0.3_m_0100.h5

# Run Helixer on each chromosome partition (can run in parallel)
nohup Helixer.py --lineage land_plant --fasta-path GDB_136/genome_chunks/GDB136_chr1H.fa --gff-output-path GDB_136/GDB_136.chr1H.helixer.gff --peak-threshold 0.9 --species GDB_136 > logs/GDB_136.helixer_chr1H.log 2>&1 &

# ... repeat for chr2H through chr7H and contigs ...

# Combine Helixer outputs
bash scripts/run_combine_helixer.sh
bash scripts/run_write_cds_helixer.sh
bash scripts/run_write_proteins_helixer.sh
```

---

### 3.5 Step 4: Integrate Predictions with EVM

```bash
conda activate pananno_jsarria

# Download EVidenceModeler if not present
# wget https://github.com/EVidenceModeler/EVidenceModeler/releases/download/EVidenceModeler-v2.1.0/EVidenceModeler-v2.1.0.tar.gz
# tar -xvf EVidenceModeler-v2.1.0.tar.gz

# Convert all predictions to EVM format
bash scripts/run_convert_suppported2EVM.sh
bash scripts/run_convert_augustus2EVM.sh
bash scripts/run_convert_TSEBRA2EVM.sh
bash scripts/run_convert_helixer2EVM.sh
bash scripts/run_convert_miniport2EVM_ALN.sh
bash scripts/run_convert_stringtie2EVM.sh
bash scripts/run_combine_abinitio_evm.sh

# Define evidence weights and run EVM integration
bash scripts/run_write_weights2.sh
bash scripts/run_runEVM.sh
bash scripts/run_removeELM.sh
bash scripts/run_write_tbl_2.sh
```

---

### 3.6 Step 5: Final Structural Refinement

#### 3.6.1 Mikado with SwissProt Plants Database

```bash
conda activate mikado_env

# Download SwissProt plants reference
wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/reference_proteomes/Eukaryota/UP000011115_3702.fasta.gz -O data/uniprot_sprot_plants.fasta.gz
gunzip data/uniprot_sprot_plants.fasta.gz

# Create Diamond database
diamond makedb --in data/uniprot_sprot_plants.fasta --db data/uniprot_sprot_plants.fasta.dmnd

# Configure and run Mikado refinement
bash scripts/run_create_mikado_tbl_updated.sh

mikado configure \
  --list GDB_136/refine_prediction/GDB_136.mikado.tbl \
  --reference data/GDB_136.fa \
  --mode permissive \
  --scoring plant.yaml \
  -bt data/uniprot_sprot_plants.fasta \
  --junctions GDB_136/portcullis/portcullis.flt.pass.junctions.bed \
  -od sprot_plants_mikado_db/ \
  sprot_plants_mikado_db/GDB_136.mikado.config.yaml

# Prepare transcripts
nohup mikado prepare -p 8 \
  --out sprot_plants_mikado_db/mikado_prepared.gtf \
  --out_fasta sprot_plants_mikado_db/mikado_prepared.fasta \
  --json-conf sprot_plants_mikado_db/GDB_136.mikado.config.yaml > logs/GDB_136.mikado.prepare_sprot.log 2>&1

# BLAST against reference proteins
nohup diamond blastx --threads 32 \
  --query sprot_plants_mikado_db/mikado_prepared.fasta \
  --db data/uniprot_sprot_plants.fasta.dmnd \
  --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore ppos btop \
  --max-target-seqs 10 --matrix blosum62 --evalue 1.0e-03 \
  --out sprot_plants_mikado_db/blast_sensitive.mikado_transcripts.tsv.gz > logs/GDB_136.diamond_sprot.log 2>&1

# Serialize and run Mikado pick
nohup mikado serialise -p 8 \
  --json-conf sprot_plants_mikado_db/GDB_136.mikado.config.yaml \
  --tsv sprot_plants_mikado_db/blast_sensitive.mikado_transcripts.tsv.gz \
  --transcripts sprot_plants_mikado_db/mikado_prepared.fasta \
  --blast_targets data/uniprot_sprot_plants.fasta \
  --junctions GDB_136/portcullis/portcullis.flt.pass.junctions.bed \
  sprot_plants_mikado_db/mikado.db > logs/GDB_136.mikado.serialise_sprot.log 2>&1 &

nohup mikado pick -p 32 \
  --json-conf sprot_plants_mikado_db/GDB_136.mikado.config.yaml \
  -db sprot_plants_mikado_db/mikado.db \
  --loci-out GDB_136.mikado_refined_prediction.run3.loci.gff3 \
  -od sprot_plants_mikado_db/ > logs/GDB_136.mikado.sprot_pick.log 2>&1 &

# Extract protein sequences
bash scripts/run_write_proteins_sprot_plants.sh
```

#### 3.6.2 PASA: Final Annotation Refinement

```bash
conda activate pasa_env

# Set up MySQL database
mysqld --initialize-insecure --datadir=$(pwd)/PASA_data
mysqld_safe --datadir=$(pwd)/PASA_data --socket=$(pwd)/PASA_data/mysql.sock --port=3307 --pid-file=$(pwd)/PASA_data/mysqld.pid &

# Configure MySQL users
mysql -u root --socket=$(pwd)/PASA_data/mysql.sock <<EOF
CREATE USER 'root'@'localhost' IDENTIFIED BY 'Password123';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

# Prepare merged transcript FASTA
gffread stringtie/stringtie.merged.junc_flt.gtf -g data/GDB_136.fa -w stringtie/mRNA_transcripts.fasta
isoseq3 collapse data/Isoseq_GDB_136_Isoseq.mm2.bam data/GDB_136_Isoseq_collapsed.mm2.gff

mkdir -p PASA
cat stringtie/mRNA_transcripts.fasta data/GDB_136_Isoseq_collapsed.mm2.fasta > PASA/mRNA_IsoSeq_merged_transcripts.fasta

# Simplify headers for Perl compatibility
awk '/^>/{print ">transcript_" ++i; next}{print}' PASA/mRNA_IsoSeq_merged_transcripts.fasta > PASA/mRNA_IsoSeq_merged_transcripts_simple.fasta

# Configure PASA alignment
nano PASA/alignAssembly.config  # Set MYSQLSERVER, DATABASE, USER, PASSWORD

# Run PASA alignment and annotation assembly
nohup $PASA_HOME/Launch_PASA_pipeline.pl \
  -c $PWD/PASA/alignAssembly.config \
  -R \
  -g data/GDB_136.fa \
  -t $PWD/PASA/mRNA_IsoSeq_merged_transcripts_simple.fasta \
  --ALIGNERS blat,gmap \
  --CPU 32 > logs/GDB136.pasa_alignment.log 2>&1 &

# Load Mikado annotations into PASA database
$PASA_HOME/scripts/Load_Current_Gene_Annotations.dbi \
  -c $PWD/PASA/alignAssembly.config \
  -g data/GDB_136.fa \
  -P sprot_plants_mikado_db/GDB_136.mikado_refined_prediction.run3.loci.gff3

# Run PASA update mode to refine annotations
nohup $PASA_HOME/Launch_PASA_pipeline.pl \
  -c $PWD/PASA/alignAssembly.config \
  -A \
  -g data/GDB_136.fa \
  -t $PWD/PASA/mRNA_IsoSeq_merged_transcripts_simple.fasta \
  --CPU 32 > logs/GDB136.pasa_compare.log 2>&1 &

# PASA output: GDB136_pasa_db.gene_structures_post_PASA_updates.final.gff3
```

---

## 4. Functional Annotation Post-Processing (COCLA)

The COCLA pipeline assigns functional annotations and confidence scores to refined gene models.

### 4.1 Setup

```bash
# Download COCLA
wget https://github.com/PGSB-HMGU/cocla2/archive/refs/heads/master.zip
unzip cocla2-master.zip

# Download required databases
mkdir -p cocla2-master/cocla_dbs
# Obtain rexdb_trep, uniprot_Magnoliophyta, uniprot_Poaceae databases

# Install InterProScan
cd my_interproscan
wget https://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.76-107.0/interproscan-5.76-107.0-64-bit.tar.gz
tar -pxvzf interproscan-5.76-107.0-64-bit.tar.gz
cd interproscan-5.76-107.0
python3 setup.py -f interproscan.properties
cd ..

# Install prot-scriber
wget https://github.com/usadellab/prot-scriber/releases/download/v0.1.6/x86_64-unknown-linux-gnu_prot-scriber
mv prot-scriber $CONDA_PREFIX/bin/
chmod +x $CONDA_PREFIX/bin/prot-scriber
```

### 4.2 Run COCLA

```bash
cd cocla2-master

# Configure config.cocla.yaml with paths to:
# - ANNO.GDB_136 = PASA final GFF3
# - COCLA databases
# - interproscan.sh path

snakemake --cores 32 -s cocla_v3_pasa.smk --configfile config.cocla.yaml

# Outputs: Multiple confidence level gene sets (0.66, 0.75, 0.8, 0.9, 0.95)
cd ..
```

---

## 5. Final Release Generation

Generate publication-ready annotation files with standardized formatting.

```bash
cd final_files

# Configure config_wrapup.yaml with:
# - GENOME path
# - ANNO (PASA GFF3)
# - COCLA output folder
# - PREFIX and SOURCE

snakemake -s make_finalfiles.snakefile --configfile config_wrapup.yaml --cores 32

# Outputs in release_v1/GDB_136/:
# - GDB_136.csic.r1.May2026.gff3 (all genes)
# - GDB_136.csic.r1.May2026.high.gff3 (high confidence)
# - GDB_136.csic.r1.May2026.low.gff3 (low confidence)
# - Protein sequences, CDS, functional annotations

cd ..
```

---

## 6. Quality Control and Validation

### 6.1 BUSCO Assessment

```bash
busco -i GDB_136/GDB_136.mikado_refined_prediction.run3.loci.aa.fa \
  -o busco_hc_analysis \
  -l poales_odb12 \
  -m proteins \
  -c 32
```

### 6.2 Gene Count Validation

```bash
# Count genes by confidence level
grep -v "#" GDB_136.csic.r1.May2026.gff3 | grep "gene" -c       # All genes
grep -v "#" GDB_136.csic.r1.May2026.high.gff3 | grep "gene" -c  # High confidence
grep -v "#" GDB_136.csic.r1.May2026.low.gff3 | grep "gene" -c   # Low confidence
```

---

## 7. Acknowledgments

This pipeline development was supported by:
- **Thomas Lux** (PGSB-HMGU) - PanAnno methodology and technical guidance
- **Manuel Spannagle** (PGSB-HMGU) - Pipeline framework and tools
- **IPK Gatersleben** - Sequencing and assembly coordination
- **BMK Gene** - RNA-seq library preparation and quality control

---

## 8. References

1. Pangenome Consortium (2024). "The barley pan-genome reveals the hidden legacy of polyploidy." *Nature*, 615, 312-322.
2. Ou, S., et al. (2023). "Benchmarking transposable element annotation methods for creation of a streamlined, comprehensive pipeline." *Genome Biology*, 24, 24.
3. Loveland, J., et al. (2022). "Comprehensive annotation of transcriptome and proteome from a patient-derived xenograft." *Nucleic Acids Research*, 50(12).

---

## 9. Troubleshooting and Notes

### Common Issues

- **LTR_Finder illegal instruction**: Compile from source (see Step 1 section)
- **MySQL connection errors in PASA**: Ensure socket path matches configuration
- **Helixer GPU memory**: Use CPU version if GPU memory insufficient (<24GB)
- **EVM integration stalls**: Check evidence file formats and sorting

### Computing Requirements

- **Storage**: ~500 GB for complete pipeline execution
- **Time**: 3-8 weeks depending on hardware and parallelization
- **Memory**: 32-64 GB RAM recommended for parallel processing
- **CPU cores**: 16-32 cores recommended (can use 8 minimum)

---

## License

This pipeline documentation and associated scripts are provided for research purposes. Refer to individual tool licenses for redistribution terms.

---

**Last updated**: October 2026  
**Pipeline version**: 1.0  
**Contact**: [Your institution/contact information]
