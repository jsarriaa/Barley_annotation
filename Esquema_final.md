# GDB_136 Definitive Annotation HOWTO

This is the minimal end-to-end process used to generate the final GDB_136 annotation.

---

## 1) Final outputs

- Final annotation GFF3:
  - `/scratch/GDB136/annotation/PASA/GDB136_pasa_db.gene_structures_post_PASA_updates.777220.gff3`
- Final release package:
  - generated from `/scratch/GDB136/annotation/final_files/`

---

## 2) Required inputs

- Genome: `genome/GDB_136.fa`
- RNA-seq paired reads: `mRNA-seq/Unknown_CP851-001U00XX_{1,2}.fasta` (or `.fq.gz`)
- IsoSeq CCS reads: `Isoseq/...ccs.bam`
- Protein database for Mikado final refinement:
  - `sprot_plants_mikado_db/uniprot_sprot_plants.fasta`

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

### A) Build evidence

1. Run EDTA and collect TE hints.
2. Run RNA-seq mapping and transcript assembly:
   - STAR index and mapping
   - BAM merge
   - Portcullis filtering
   - StringTie assembly and merge
3. Run IsoSeq mapping with minimap2 and convert to hints.
4. Run miniprot/miniprothint-based protein evidence and generate hints.
5. Merge all hints (RNA + IsoSeq + TE + protein).

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

## 6) Main command sequence

```bash
# RNA-seq and transcripts
bash scripts/run_STAR.sh
bash scripts/run_STAR_mapping.sh
bash scripts/run_merge_STAR_bams.sh
bash scripts/run_portcullis_prep.sh
bash scripts/run_portcullis_filter.sh
bash scripts/run_stringtie.sh
bash scripts/run_merge_stringtie.sh

# IsoSeq / protein / TE hints
bash scripts/run_Isoseq_minimap2.sh
bash scripts/run_bam2gff.sh
bash scripts/run_hints_miniprot.sh
bash scripts/run_merge_EDTA.sh
bash scripts/run_combine_all_hints.sh

# Predictions and integration
bash scripts/run_agustus.sh
bash scripts/run_tsebra.sh
bash scripts/run_combine_helixer.sh
bash scripts/run_runEVM.sh

# Final Mikado + PASA phase
# (configure/prepare/serialise/pick in mikado)
# (PASA -R then PASA -A)
```
