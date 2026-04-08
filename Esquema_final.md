# GDB_136 Definitive Annotation HOWTO

This is the mandatory end-to-end process used to generate the final GDB_136 annotation.

---

## 1) Final outputs

- Final annotation GFF3:
  - `/scratch/GDB136/annotation/PASA/GDB136_pasa_db.gene_structures_post_PASA_updates.777220.gff3`
- Final release package:
  - generated from `/scratch/GDB136/annotation/final_files/`

---

## 2) Required inputs

- Genome: `data/GDB_136.fa`
- RNA-seq paired reads: 15 paired libraries (`Unknown_CP851-001U0001` to `Unknown_CP851-001U0015`), as `.fq.gz` or converted `.fasta`
- IsoSeq CCS reads: `data/IsoSeq.bam`
- Protein database for Mikado final refinement:
  - `sprot_plants_mikado_db/uniprot_sprot_plants.fasta`

Expected data layout:

```bash
data/
├── GDB_136.fa
├── IsoSeq.bam
└── mRNA-seq/
    ├── Unknown_CP851-001U0001_1.fq.gz
    ├── Unknown_CP851-001U0001_2.fq.gz
    └── ... up to ...
        Unknown_CP851-001U0015_1.fq.gz
        Unknown_CP851-001U0015_2.fq.gz
```

---

## 3) Environments

- `barley_annotation`
- `portcullis_env`
- `mikado_env`
- `pananno`
- `pasa_env`
- `helixer`
- `augustus`

---

## 4) Pipeline steps

### 0) Mandatory preparation

1. Split genome by pseudochromosomes/contigs:
  - `mkdir -p genome_by_contigs && cd genome_by_contigs`
  - `awk '/^>/{s=substr($1,2); close(f); f=s".fasta"} {print > f}' ../data/GDB_136.fa`
2. Prepare IsoSeq FASTA from BAM:
  - `samtools fasta data/IsoSeq.bam > data/IsoSeq.fa`
3. Prepare mRNA-seq FASTA files when needed:
  - `bash scripts/process_rnaseq.sh`
4. Prepare/read index files:
  - `bash scripts/run_indexfasta.sh`
  - `bash scripts/run_minimap2_index.sh` (or `bash scripts/run_build_minimap2_index.sh`)
  - `bash scripts/run_miniprot.sh`
5. Prepare reference chunks for Helixer/partition-based steps:
  - `bash scripts/run_split_genome.sh`

### 1) Mandatory TE annotation (EDTA)

1. Activate EDTA environment (`EDTA 2.2.2`).
2. Run EDTA pipeline script:
  - `nohup bash scripts/run_edta.sh > logs/EDTA/run_edta.log 2>&1 &`
3. Convert TE output to hints:
  - `bash scripts/run_merge_EDTA.sh`
  - `python3 scripts/run_EDTA2hints.py`

### A) Build evidence

1. Run RNA-seq mapping and transcript assembly:
   - STAR index and mapping
   - BAM merge
   - Portcullis filtering
   - StringTie assembly and merge
2. Run IsoSeq mapping with minimap2 and convert to hints.
3. Run miniprot/miniprothint protein evidence and generate hints:
  - `bash scripts/run_hints_miniprot.sh`
  - `bash scripts/run_score_miniprot.sh`
  - `bash scripts/run_hints_miniprot_2.sh`
  - `bash scripts/run_aln2hints.sh`
  - `bash scripts/run_aln2hints_hc.sh`
  - `bash scripts/run_join_prothints.sh`
4. Build RNA hints and merge all evidence hints (RNA + IsoSeq + TE + protein).

### B) Build gene predictions

6. Run AUGUSTUS with merged hints and extract supported models.
7. Run TSEBRA selection.
8. Run Helixer and combine chromosome outputs.
9. Convert inputs to EVM format, apply weights, run EVM, and keep cleaned EVM output.

### C) Final structural refinement

10. Run Mikado with SwissProt plants database:
    - final retained file:
      - `sprot_plants_mikado_db/GDB_136.mikado_refined_prediction.run3.loci.gff3`
11. Run PASA:
    - prepare merged transcript FASTA (StringTie + IsoSeq)
    - run PASA alignment assembly
    - load Mikado run3 annotation
    - run PASA update mode (`-A`)
12. Keep the PASA-updated GFF3 as final annotation:
    - `PASA/GDB136_pasa_db.gene_structures_post_PASA_updates.777220.gff3`

---

## 5) Final release generation

## 5) COCLA post-processing (mandatory before final release)

Run COCLA on the selected annotation to generate curated protein-level support files used by the release step.

1. Prepare COCLA workspace and databases:
  - `cd /scratch/GDB136/annotation/cocla2-master`
  - Ensure Diamond DBs exist in `cocla_dbs/`:
    - `rexdb_trep.dmnd`
    - `uniprot_Magnoliophyta_reviewed_collapsed_170220.fasta.dmnd`
    - `uniprot_Poaceae_complete_collapsed_170220.fasta.dmnd`
2. Ensure required tools are available:
  - `prot-scriber`
  - `interproscan.sh` (configured path in the pipeline/config)
  - `diamond`, `gt`, `snakemake`
3. Configure `config.cocla.yaml`:
  - `ANNO.GDB_136` = `/scratch/GDB136/annotation/sprot_plants_mikado_db/GDB_136.mikado_refined_prediction.run3.loci.gff3`
  - `COCLA.trep` = `/scratch/GDB136/annotation/cocla2-master/cocla_dbs/rexdb_trep.dmnd`
  - `COCLA.sprot` = `/scratch/GDB136/annotation/cocla2-master/cocla_dbs/uniprot_Magnoliophyta_reviewed_collapsed_170220.fasta.dmnd`
  - `COCLA.poales` = `/scratch/GDB136/annotation/cocla2-master/cocla_dbs/uniprot_Poaceae_complete_collapsed_170220.fasta.dmnd`
4. Run COCLA:

```bash
snakemake --cores 32 -s cocla_v3_pasa.smk --configfile config.cocla.yaml
```

5. Keep the generated COCLA output folder for wrap-up:
  - `/scratch/GDB136/annotation/PASA/cocla2/GDB_136/cocla`

---

## 6) Final release generation

Inside `/scratch/GDB136/annotation/final_files`:

1. Configure `config_wrapup.yaml`:
   - `GENOME`: `/scratch/GDB136/annotation/final_files/GDB_136.fa`
   - `ANNO`: `/scratch/GDB136/annotation/PASA/GDB136_pasa_db.gene_structures_post_PASA_updates.777220.gff3`
   - `COCLA`: `/scratch/GDB136/annotation/PASA/cocla2/GDB_136/cocla`
2. Ensure file exists:
   - `/scratch/GDB136/annotation/PASA/cocla2/GDB_136/cocla/HRD.tsv`
3. Run:

```bash
snakemake -s make_finalfiles.snakefile --configfile config_wrapup.yaml --cores 32
```

---

## 7) Main command sequence

```bash
# Mandatory preparation
mkdir -p genome_by_contigs
cd genome_by_contigs
awk '/^>/{s=substr($1,2); close(f); f=s".fasta"} {print > f}' ../data/GDB_136.fa
cd ..

samtools fasta data/IsoSeq.bam > data/IsoSeq.fa
bash scripts/process_rnaseq.sh

bash scripts/run_indexfasta.sh
bash scripts/run_minimap2_index.sh
bash scripts/run_miniprot.sh
bash scripts/run_split_genome.sh

# Mandatory EDTA block
nohup bash scripts/run_edta.sh > logs/EDTA/run_edta.log 2>&1 &
bash scripts/run_merge_EDTA.sh
python3 scripts/run_EDTA2hints.py

# RNA-seq and transcripts
bash scripts/run_STAR.sh
bash scripts/run_STAR_mapping.sh
bash scripts/run_merge_STAR_bams.sh
bash scripts/run_portcullis_prep.sh
bash scripts/run_portcullis_filter.sh
bash scripts/run_juntools_filter.sh
bash scripts/run_stringtie.sh
bash scripts/run_merge_stringtie.sh

# IsoSeq / RNA hints
bash scripts/run_Isoseq_minimap2.sh
bash scripts/run_bam2gff.sh
bash scripts/run_sortBambyreads.sh
bash scripts/run_filterbam.sh
bash scripts/run_sort_flt_bam.sh
bash scripts/run_bam2hints.sh
bash scripts/run_filterIntronsFindStrand.sh
bash scripts/run_wig2hints.sh
bash scripts/run_blat2hints.sh
bash scripts/run_merge_extrinsic_hints.sh
bash scripts/run_combine_all_hints.sh

# Miniprot mandatory block
bash scripts/run_hints_miniprot.sh
bash scripts/run_score_miniprot.sh
bash scripts/run_hints_miniprot_2.sh
bash scripts/run_aln2hints.sh
bash scripts/run_aln2hints_hc.sh
bash scripts/run_join_prothints.sh

# Predictions and integration
bash scripts/run_agustus.sh
bash scripts/run_tsebra.sh
bash scripts/run_tsebra2gff3.sh
bash scripts/run_tsebra_selection.sh
bash scripts/run_combine_helixer.sh
bash scripts/run_convert_suppported2EVM.sh
bash scripts/run_convert_augustus2EVM.sh
bash scripts/run_convert_TSEBRA2EVM.sh
bash scripts/run_convert_helixer2EVM.sh
bash scripts/run_convert_miniport2EVM_ALN.sh
bash scripts/run_convert_stringtie2EVM.sh
bash scripts/run_combine_abinitio_evm.sh
bash scripts/run_write_weights2.sh
bash scripts/run_runEVM.sh
bash scripts/run_removeELM.sh
bash scripts/run_write_tbl_2.sh

# Final Mikado + PASA phase
bash scripts/run_create_mikado_tbl_updated.sh
# mikado configure/prepare/serialise/pick (run3 with SwissProt plants)
bash scripts/run_write_proteins_sprot_plants.sh
# PASA: Launch_PASA_pipeline.pl -R, then Load_Current_Gene_Annotations.dbi, then Launch_PASA_pipeline.pl -A

# COCLA
cd cocla2-master
snakemake --cores 32 -s cocla_v3_pasa.smk --configfile config.cocla.yaml
cd ..

# Final packaging
cd final_files
snakemake -s make_finalfiles.snakefile --configfile config_wrapup.yaml --cores 32
```
