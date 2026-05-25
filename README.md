# Barley_annotation
De novo annotation of a barley landrace, part of my PhD

We sequenced and ensambled a new Barley landrace originary from Iraq. We follow the same protocols and pipelines as the Pangenome V2 of  (reference), actually in colaboration with IPK groups in charge of sequencing (reference) and ensambling (reference) it.
Following the most comparable approach, de novo annotation has been reported, following the pantranscriptome pipeline. Acknoledgment to Manuel Spannagle (ocomoseescriba) but specially to our collaborator Thomas Lux.

For this, we own 5 tissues 3 replicates of mRNA-seq and IsoSeq from a pool of root and shoot, performed by the company BMK-GENE.
Raw data is free to access at ENA: (Links)
Assembly:
IsoSeq:
mRNA-seq:

Original code may be found:
Link to thomas pananno repo

##
Maybe here a summary of the pipeline
##

# NOTA
Han de ser 15x2 mRNA en fastq y un bam del IsoSeq. Cuando lo subas a ENA sube bien los enlaces de descarga. Debería quedar algo así en la carpeta de data:

```
/genoma/GDB136/Anno/data$ ls -lh | sed 's/ -> .*//'
total 136K
lrwxrwxrwx 1 jsarria jsarria   84 Feb 25 11:24 GDB_136.fa
-rwxr-xr-x 1 jsarria jsarria 4.2G Feb 25 12:09 IsoSeq.bam
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0001_good_1.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0001_good_2.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0002_good_1.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0002_good_2.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0003_good_1.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0003_good_2.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0004_good_1.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0004_good_2.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0005_good_1.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0005_good_2.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0006_good_1.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0006_good_2.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0007_good_1.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0007_good_2.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0008_good_1.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0008_good_2.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0009_good_1.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0009_good_2.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0010_good_1.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0010_good_2.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0011_good_1.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0011_good_2.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0012_good_1.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0012_good_2.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0013_good_1.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0013_good_2.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0014_good_1.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0014_good_2.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0015_good_1.fq.gz
lrwxrwxrwx 1 jsarria jsarria  132 Feb 25 11:36 Unknown_CP851-001U0015_good_2.fq.gz
-rw-r--r-- 1 jsarria jsarria 2.2K Feb 25 11:38 data_md5.txt
-rw-r--r-- 1 jsarria jsarria  462 Feb 25 11:37 sampleName_clientId.txt
```


# Split genome assembly by pseudochromosomes and unplaced contigs;
```
mkdir genome_by_contigs
cd genome_by_contigs/
awk '/^>/{s=substr($1,2); close(f); f=s".fasta"} {print > f}' ../data/GDB_136.fa
```

# Prepare Isoseq data (bam) into fasta
``` samtools fasta data/IsoSeq.bam > data/IsoSeq.fa ```
```
[M::bam2fq_mainloop] discarded 0 singletons
[M::bam2fq_mainloop] processed 5666378 reads
```

# Prepare environment for huge part of the pipeline
```
mkdir scripts
wget https://raw.githubusercontent.com/jsarriaa/Barley_annotation/blob/main/environment.yml -O scripts/environment.yml
conda env create -f scripts/environment.yml
```

# Prepare mRNA-seq data
```
conda activate pananno_jsarria
cd data/
bash ../scripts/process_rnaseq.sh
# ...
# Combining all individual FASTA files...
# Successfully created combined file: combined_mrna_transcripts.fa
# The file contains this many sequences:
# 1674071604
# Script finished.
rm *fq.gz
```


# Prepare EDTA environment
```
conda create -n EDTA_env -c conda-forge -c bioconda edta=2.2.2 -y
EDTA.pl --version

#########################################################
##### Extensive de-novo TE Annotator (EDTA) v2.2.2  #####
##### Shujun Ou (shujun.ou.1@gmail.com)             #####
#########################################################
```

######
Section for TE elements
######
```
conda activate EDTA_env

check dependencies:
gt -version
gt (GenomeTools) 1.6.5

# If:
ltr_finder
Illegal instruction
# You will haev to compile from source:

git clone https://github.com/xzhub/LTR_Finder.git
cd LTR_Finder/source
make
cp ltr_finder $CONDA_PREFIX/bin/
cd ../..
rm -rf LTR_Finder

ltr_finder -h    
ltr_finder v1.07

nohup bash scripts/run_edta.sh > logs/EDTA/run_edta.log 2>&1 &
```

NOTE: not running all chromosomes again, since there were already done previously with same command. Copying and renamin to fit:
```
import os

root_dir = 'EDTA'

# We walk top-down=False so we rename children before parents (like -depth)
for root, dirs, files in os.walk(root_dir, topdown=False):
    for name in files + dirs:
        if name == root_dir or name.startswith('GDB136_'):
            continue
        
        old_path = os.path.join(root, name)
        new_path = os.path.join(root, f"GDB136_{name}")
        
        print(f"Renaming: {name} -> GDB136_{name}")
        os.rename(old_path, new_path)
```

# Run STAR
```
STAR --version
2.7.11b
bash scripts/run_STAR.sh
bash scripts/run_STAR_mapping.sh
bash scripts/run_merge_STAR_bams.sh
```

# Run miniprot
```
miniprot --version
0.18-r281
bash scripts/run_miniprot.sh
```

# Run minimap
```
minimap2 --version
2.30-r1287
bash scripts/run_minimap2_index.sh
```

# indexing fasta with samtools
```
samtools --version
samtools 1.22.1
Using htslib 1.22.1
bash scripts/run_indexfasta.sh
```


# Portcullis to filter and analyze splice junctions

portcullis --version                                                                                                          
portcullis 1.2.4

bash scripts/run_portcullis_prep.sh
bash scripts/run_portcullis_junc.sh
bash scripts/run_portcullis_filter.sh

#

stringtie --version
3.0.1
bash scripts/run_stringtie.sh
bash scripts/run_merge_stringtie.sh

Filter or markup GTF files (stringtie) based on provided junctions (portcullis)
junctools --version
1.2.4
bash scripts/run_juntools_filter.sh


###

wget https://ftp.uniprot.org/pub/databases/uniprot/current_release/uniref/uniref50/uniref50.fasta.gz 
gunzip uniref50.fasta.gz
mv uniref50.fasta data/

#conda create --name mikado_env -c bioconda -c conda-forge python=3.10 mikado=2.3.4 sqlalchemy=1.4.41
mikado --version
Mikado v2.3.4

mkdir transcripts
nano transcripts/GDB_136.mikado.tbl
print: `stringtie/stringtie.merged.junc_flt.gtf	st	True	1	False	True	True`
bash scripts/run_mikado_configure.sh

And you must get something like:
```
grep -v "#" transcripts/GDB_136.mikado.config.yaml
db_settings:
  db: mikado.db
  dbtype: sqlite
pick:
  alternative_splicing:
    pad: true
  chimera_split:
    blast_check: true
    blast_params:
      leniency: STRINGENT
    execute: true
    skip:
    - false
  files:
    input: mikado_prepared.gtf
    monoloci_out: ''
    output_dir: transcripts
    subloci_out: ''
  run_options:
    intron_range:
    - 60
    - 10000
  scoring_file: plant.yaml
prepare:
  files:
    exclude_redundant:
    - true
    gff:
    - stringtie/stringtie.merged.junc_flt.gtf
    labels:
    - st
    output_dir: transcripts
    reference:
    - false
    source_score:
      st: 1.0
    strand_specific_assemblies:
    - stringtie/stringtie.merged.junc_flt.gtf
    strip_cds:
    - true
  max_intron_length: 1000000
  minimum_cdna_length: 200
  strand_specific: false
reference:
  genome: data/GDB_136.fa
seed: 0
serialise:
  codon_table: 0
  files:
    blast_targets:
    - uniref50.fasta
    junctions:
    - portcullis/GDB_136.junctions.bed
    output_dir: transcripts
    transcripts: mikado_prepared.fasta
  max_regression: 0.2
  substitution_matrix: blosum62
threads: 1
```
bash scripts/run_mikado_prepare.sh

# Running prodigal
prodigal
PRODIGAL v2.6.3 [February, 2016]         

bash scripts/run_prodigal.sh

# Run diamond

diamond --version
diamond version 2.1.13

diamond makedb --in data/uniref50.fasta -d transcripts/uniref50.fasta.dmnd
bash scripts/run_diamond.sh

# Mikado again
bash scripts/run_mikado_serialise.sh

### NOTE: 
plant.yaml and config file must be upload to this repo, do not forget, silly rat


bash scripts/run_mikado_pick.sh

# Now writing the cds using:
gffread --version
0.12.7

bash scripts/run_write_cds.sh
bash scripts/run_cds2aa.sh    #also as AA

# Iso-seq data
minimap2 --version
2.26-r1175

mkdir minimap2_index
minimap2 -d minimap2_index/GDB_136.mmi data/GDB_136.fa > logs/GDB_136.minimap2_idx.log 2>&1 &

bash scripts/run_Isoseq_minimap2.sh

[M::worker_pipeline::48488.579*31.67] mapped 196011 sequences
[M::main] Version: 2.26-r1175
[M::main] CMD: minimap2 -ax splice:hq --junc-bed portcullis/portcullis.flt.pass.junctions.bed --cs=long -t 32 -uf -L --eqx -2 --secondary=no minimap2_index/GDB_136.mmi data/IsoSeq.fa
[M::main] Real time: 48490.043 sec; CPU: 1535854.341 sec; Peak RSS: 33.319 GB
Alignment and sorting completed successfully. Output saved to: data/Isoseq_GDB_136_Isoseq.mm2.bam

bash scripts/run_bam2gff.sh

wget -O data/uniref_tax38820_id0.5.fasta.gz "https://rest.uniprot.org/uniref/stream?compressed=true&download=true&format=fasta&query=%28%28identity%3A0.5%29+AND+%28taxonomy_id%3A38820%29%29"
gunzip data/uniref_tax38820_id0.5.fasta.gz

nohup miniprot -t 32 --gff miniprot/GDB_136.mpi data/uniref_tax38820_id0.5.fasta > miniprot/GDB_136.prots.miniprot.gff 2> logs/GDB_136_miniprot_ref.log &

bash scripts/run_hints_miniprot.sh

[M::main] Version: 0.13-r248
[M::main] CMD: miniprot -I -u --outn=1 --aln -t 32 miniprot/GDB_136.mpi data/uniref_tax38820_id0.5.fasta
[M::main] Real time: 3555.146 sec; CPU: 101868.521 sec; Peak RSS: 72.034 GB

End time: lun 13 abr 2026 15:56:00 CEST
Miniprot alignment completed successfully.

# Downloading miniprot-boundary-scorer
git clone https://github.com/tomasbruna/miniprot-boundary-scorer.git
cd miniprot-boundary-scorer && make
cd ..

bash scripts/run_score_miniprot.sh

# Now install miniprothint
git clone https://github.com/tomasbruna/miniprothint.git

bash scripts/run_hints_miniprot_2.sh

# Install GALBA to have acces to aln2hins.pl
git clone https://github.com/Gaius-Augustus/GALBA.git
# Ojo que realmente esto no lo has usao eh, algo falla

nano bash scripts/run_aln2hints_hc.sh

# Get Augustus to run join_mult_hits.pl
git clone https://github.com/Gaius-Augustus/Augustus/

bash scripts/run_join_prothints.sh

#####
# Now working with m-RNA seq back
##### 

bash scripts/run_sortBambyreads.sh
bash scripts/run_filterbam.sh
bash scripts/run_sort_flt_bam.sh

bash scripts/run_bam2hints.sh
bash scripts/run_filterIntronsFindStrand.sh
bash scripts/bam2wig.sh
bash scrips/run_wig2hints.sh
bash scripts/run_merge_extrinsic_hints.sh
bash scripts/run_blat2hints.sh

## Integrating EDTA
bash scripts/run_merge_EDTA.sh
python3 scripts/run_EDTA2hints.py
bash scripts/run_combine_all_hints.sh
All hints combined successfully. Final file: GDB_136/hints.all_combined.gff

###
# Now working with abinitio
###

bash scripts/abinitio_setup.sh

augustus
AUGUSTUS (3.5.0) is a gene prediction tool.
Sources and documentation at https://github.com/Gaius-Augustus/Augustus

# Ten en cuenta que has de referenciar bien la descarga del repo de Thomas para que tenga acceso a ficheros como:
# EXTRINSIC_CFG="pananno/extrinsic.cfg"

nohup bash scripts/run_augustus.sh > scripts/augustus_progress.log 2>&1 &
#Monitorizing:
#TOTAL=9252; DONE=$(find new_anno/GDB_136/abinitio/ -name "*.gff" -type f -not -empty | wc -l); PERC=$(awk "BEGIN {printf \"%.2f\", $DONE*100/$TOTAL}"); echo "Progress: $DONE / $TOTAL ($PERC%)"

bash scripts/run_combine_augustus.sh

#Check existing: 
scripts/extract_supported.py

bash scripts/run_extract_supported.sh

#Add properly to the script tsebra:
which tsebra.py

bash scripts/run_tsebra.sh
bash scripts/run_tsebra2gff3.sh
#Same here, fix the path:
bash scripts/run_tsebra_selection.sh






# Start with the combine_predictions.smk

wget https://github.com/EVidenceModeler/EVidenceModeler/releases/download/EVidenceModeler-v2.1.0/EVidenceModeler-v2.1.0.tar.gz
# untar and update the path of the tools on the following scripts:
tar -xvf EVidenceModeler-v2.1.0.tar.gz

bash scripts/run_convert_suppported2EVM.sh
bash scripts/run_convert_augustus2EVM.sh

bash scripts/run_convert_TSEBRA2EVM.sh
bash scripts/run_convert_miniport2EVM_ALN.sh
bash scripts/run_convert_stringtie2EVM.sh
bash scripts/run_combine_augustus_mikado2EVM.sh
bash scripts/run_write_weights.sh
bash scripts/run_runEVM.sh
bash scripts/run_removeELM.sh
bash scripts/run_write_tbl.sh
bash scripts/run_mikado_configure2.sh

bash scripts/run_split_genome.sh

# first we need to install helixer
# https://github.com/usadellab/Helixer/blob/main/docs/manual_install.md
git clone https://github.com/weberlab-hhu/Helixer.git
# And created environment
conda activate helixer
conda install -c conda-forge hdf5=1.10.6 -y
# Download plant_model
# wget https://zenodo.org/records/10836346/files/land_plant_v0.3_m_0100.h5?download=1
mv 'land_plant_v0.3_m_0100.h5?download=1' land_plant_v0.3_m_0100.h5

#If: 
Testing whether helixer_post_bin is correctly installed
helixer_post_bin: error while loading shared libraries: libhdf5.so.103: cannot open shared object file: No such file or directory

#Try:
find $CONDA_PREFIX -name "libhdf5.so.103"
/scratch/software-phgv2/miniconda3/envs/helixer/lib/libhdf5.so.103
#And:
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH

nohup Helixer.py --lineage land_plant --fasta-path GDB_136/genome_chunks/GDB136_chr1H.fa --gff-output-path GDB_136/GDB_136.chr1H.helixer.gff --peak-threshold 0.9 --species GDB_136 > logs/GDB_136.helixer_chr1H.log 2>&1 &
nohup Helixer.py --lineage land_plant --fasta-path GDB_136/genome_chunks/GDB136_chr2H.fa --gff-output-path GDB_136/GDB_136.chr2H.helixer.gff --peak-threshold 0.9 --species GDB_136 > logs/GDB_136.helixer_chr2H.log 2>&1 &
nohup Helixer.py --lineage land_plant --fasta-path GDB_136/genome_chunks/GDB136_chr3H.fa --gff-output-path GDB_136/GDB_136.chr3H.helixer.gff --peak-threshold 0.9 --species GDB_136 > logs/GDB_136.helixer_chr3H.log 2>&1 &nohup Helixer.py --lineage land_plant --fasta-path GDB_136/genome_chunks/GDB136_chr4H.fa --gff-output-path GDB_136/GDB_136.chr4H.helixer.gff --peak-threshold 0.9 --species GDB_136 > logs/GDB_136.helixer_chr4H.log 2>&1 &
nohup Helixer.py --lineage land_plant --fasta-path GDB_136/genome_chunks/GDB136_chr5H.fa --gff-output-path GDB_136/GDB_136.chr5H.helixer.gff --peak-threshold 0.9 --species GDB_136 > logs/GDB_136.helixer_chr5H.log 2>&1 &
nohup Helixer.py --lineage land_plant --fasta-path GDB_136/genome_chunks/GDB136_chr6H.fa --gff-output-path GDB_136/GDB_136.chr6H.helixer.gff --peak-threshold 0.9 --species GDB_136 > logs/GDB_136.helixer_chr6H.log 2>&1 &
nohup Helixer.py --lineage land_plant --fasta-path GDB_136/genome_chunks/GDB136_chr7H.fa --gff-output-path GDB_136/GDB_136.chr7H.helixer.gff --peak-threshold 0.9 --species GDB_136 > logs/GDB_136.helixer_chr7H.log 2>&1 &
nohup Helixer.py --lineage land_plant --fasta-path GDB_136/genome_chunks/contigs.fa --gff-output-path GDB_136/GDB_136.contigs.helixer.gff --peak-threshold 0.9 --species GDB_136 > logs/GDB_136.helixer_contigs.log 2>&1 &

bash scripts/run_combine_helixer.sh
# Change back to pananno conda
bash scripts/run_write_cds_helixer.sh
bash scripts/run_write_proteins_helixer.sh

# Then, come back to combine_predictions...
# rerun:
bash scripts/run_convert_suppported2EVM.sh
bash scripts/run_convert_TSEBRA2EVM.sh
bash scripts/run_convert_augustus2EVM.sh

# Those are new:
bash scripts/run_convert_helixer2EVM.sh
bash scripts/run_combine_abinitio_evm.sh

# Come back to old scripts
bash scripts/run_convert_miniport2EVM_ALN.sh
bash scripts/run_convert_stringtie2EVM.sh
# (not even sure if needed to rerun all this but whocares)

bash scripts/run_write_weights2.sh
bash scripts/run_runEVM.sh

bash scripts/run_removeELM.sh

bash scripts/run_write_tbl_2.sh

conda activate mikado_env
bash scripts/run_mikado_configure.sh

bash scripts/run_mikado_prepare.sh 
bash scripts/run_prodigial.sh

conda activate pananno
bash scripts/run_diamond.sh

bash scripts/run_mikado_serialise.sh
bash scripts/run_mikado_pick.sh

conda activate pananno
bash scripts/run_write_cds2.sh

bash scripts/run_write_proteins.sh

cat GDB_136/GDB_136.mikado_refined_prediction.RUN1.loci.aa.fa | grep ">" -c
27141
cat GDB_136/GDB_136.mikado_refined_prediction.RUN1.loci.cds.fa | grep ">" -c
27274

grep "gene" -c mikado/GDB_136.mikado_refined_prediction.RUN1.loci.gff3
24457

# to check numbers of isoforms:
tail -n +2 final_results/GDB_136.mikado_refined_prediction.RUN2.loci.metrics.tsv | awk '{print $1}' | awk -F'.' '{print $NF}' | sort -n | uniq -c | sort -nr

#######################
#######################
# Thomas: I think the loss of gene models is caused by mikado discarding too many models due to low blast results.
# So we are running mikado with  sprot_plant database.

wget https://mikado.readthedocs.io/en/stable/_downloads/ddeb548a6ba8c33afdeaf70127bd6f29/uniprot_sprot_plants.fasta.gz -O data/uniprot_sprot_plants.fasta

mkdir sprot_plants_mikado_db
diamond makedb --in data/uniprot_sprot_plants.fasta --db data/uniprot_sprot_plants.fasta.dmnd
bash scripts/run_create_mikado_tbl_updated.sh

# tbl is not ok, creating it amnually

cat << EOF > GDB_136/refine_prediction/GDB_136.mikado.tbl
GDB_136/augustus.hints.all_combined.supported.gff3      augsupp True    8       True    True    False   False
GDB_136/GDB_136.run2.EVM.no_ELM.gff3    evm     True    8       True    True    False   False
mikado/GDB_136.mikado_refined_prediction.RUN1.loci.gff3 mik     True    5       False   True    False   False
miniprot/GDB_136.uniref_plants_c50.miniprot_scored.gff  prot    True    5       False   True    False   False
GDB_136/GDB_136.helixer.combined.gff3   helixer True    8       True    True    False   False
EOF

mikado configure \
  --list GDB_136/refine_prediction/GDB_136.mikado.tbl \
  --reference data/GDB_136.fa \
  --mode permissive \
  --scoring plant.yaml \
  --copy-scoring plant.yaml \
  -bt sprot_plants_mikado_db/uniprot_sprot_plants.fasta \
  --junctions GDB_136/portcullis/portcullis.flt.pass.junctions.bed \
  -od sprot_plants_mikado_db/ \
  sprot_plants_mikado_db/GDB_136.mikado.config.yaml

nohup mikado prepare -p 8 --out sprot_plants_mikado_db/mikado_prepared.gtf --out_fasta sprot_plants_mikado_db/mikado_prepared.fasta --json-conf sprot_plants_mikado_db/GDB_136.mikado.config.yaml > logs/GDB_136.mikado.prepare_sprot.log 2>&1

nohup diamond blastx --threads 32 --query sprot_plants_mikado_db/mikado_prepared.fasta --outfmt 6 qseqid sseqid pident length mismatch gapopen qstart qend sstart send evalue bitscore ppos btop --max-target-seqs 10 --matrix blosum62 --evalue 1.0e-03 --db /scratch/GDB136/new_anno/data/uniprot_sprot_plants.fasta.dmnd --salltitles --sensitive --compress 1 --out sprot_plants_mikado_db/blast_sensitive.mikado_transcripts.tsv.gz > logs/GDB_136.diamond_sprot.log 2>&1

nohup mikado serialise -p 8 \
  --json-conf sprot_plants_mikado_db/GDB_136.mikado.config.yaml \
  --tsv sprot_plants_mikado_db/blast_sensitive.mikado_transcripts.tsv.gz \
  --transcripts sprot_plants_mikado_db/mikado_prepared.fasta \
  --blast_targets data/uniprot_sprot_plants.fasta \
  --junctions GDB_136/portcullis/portcullis.flt.pass.junctions.bed \
  sprot_plants_mikado_db/mikado.db > logs/GDB_136.mikado.serialise_sprot.log 2>&1 &

nohup mikado pick -p 32   --json-conf sprot_plants_mikado_db/GDB_136.mikado.config.yaml   -db sprot_plants_mikado_db/mikado.db   --monoloci-out GDB_136.mikado_refined_prediction.run3.monoloci.gff3   --loci-out GDB_136.mikado_refined_prediction.run3.loci.gff3   -od sprot_plants_mikado_db/ > logs/GDB_136.mikado.sprot_pick.log 2>&1 &

grep $'\tgene' sprot_plants_mikado_db/GDB_136.mikado_refined_prediction.run3.loci.gff3 -c
74993
# Without the unplaced contigs this number was 74122

gffread -g data/GDB_136.fa sprot_plants_mikado_db/GDB_136.mikado_refined_prediction.run3.loci.gff3 -x sprot_plants_mikado_db/GDB_136.mikado_refined_prediction.run3.loci.cds.fa
bash scripts/run_write_proteins_sprot_plants.sh
busco -i sprot_plants_mikado_db/GDB_136.mikado_refined_prediction.run3.loci.aa.fa -o busco_GDB136_anno_mikado_sprot -l poales_odb12 -m proteins -c 32
C:97.9%[S:66.9%,D:31.0%],F:1.0%,M:1.1%,n:6282


######
FINISHED MIKADO PIPELINE; Now refining the result with PASA
######

gffread stringtie/stringtie.merged.junc_flt.gtf -g data/GDB_136.fa -w stringtie/mRNA_transcripts.fasta

conda install -c bioconda isoseq3
isoseq3 --version
isoseq 4.3.0 (commit v4.3.0)

isoseq3 collapse data/Isoseq_GDB_136_Isoseq.mm2.bam data/GDB_136_Isoseq_collapsed.mm2.gff 

mkdir PASA
cat stringtie/mRNA_transcripts.fasta data/GDB_136_Isoseq_collapsed.mm2.fasta > PASA/mRNA_IsoSeq_merged_transcripts.fasta

conda create -n pasa_env -c bioconda -c conda-forge \
    pasa mysql-server mysql-client isoseq3 samtools perl-dbd-mysql

conda activate pasa_env

mysqld --initialize-insecure --datadir=$(pwd)/PASA_data

#Running it at bg
mysqld_safe --datadir=$(pwd)/PASA_data \
            --socket=$(pwd)/PASA_data/mysql.sock \
            --port=3307 \
            --pid-file=$(pwd)/PASA_data/mysqld.pid &

mysql -u root --socket=$(pwd)/PASA_data/mysql.sock
# Create user
mysql> CREATE USER 'root'@'%' IDENTIFIED BY 'Password123';
mysql> GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';
FLUSH PRIVILEGES;
EXIT;

nano PASA/alignAssembly.config 

cat nano PASA/alignAssembly.config 
DATABASE=GDB136_pasa_db
MYSQLDB=GDB136_pasa_db
MYSQLSERVER=127.0.0.1;port=3307
MYSQL_RW_USER=root
MYSQL_RW_PASSWORD=Password123
MIN_PERCENT_ALIGNED=90
MIN_AVG_PER_ID=95
NUM_BP_PERFECT_SPLICE_BOUNDARY=0
CLUSTERING_DIST=100
USE_GMAP_LARGE=0

# Fix bugged characters
sed -i 's/\r$//' PASA/alignAssembly.config

#Set you PASA_HOME, in my case:
export PASA_HOME=/scratch/software-phgv2/miniconda3/envs/pasa_env/opt/pasa-2.5.3

$PASA_HOME/scripts/test_mysql_connection.dbi -c PASA/alignAssembly.config
usage: /scratch/software-phgv2/miniconda3/envs/pasa_env/opt/pasa-2.5.3/scripts/test_mysql_connection.dbi user password host database

gmap --version
GMAP version 2025-07-31 called with args: gmap.sse42 --version

blat 
blat - Standalone BLAT v. 39x1 fast sequence search command line tool

# Using a template to provide to PASA a config necessary file (doing this to actually not delete the template, just in case)
cd $PASA_HOME/pasa_conf
cp pasa.CONFIG.template conf.txt
cd [Working_directory]

# Use proper server path
MY_SOCKET=/scratch/GDB136/new_anno/PASA_data/mysql.sock
sed -i "s|^MYSQLSERVER=.*|MYSQLSERVER=localhost;mysql_socket=$MY_SOCKET|" PASA/alignAssembly.config

# provide root to localhost (socket connexion)
mysql -S /scratch/GDB136/new_anno/PASA_data/mysql.sock -u root -p
Enter password: 
# Password is empty

ALTER USER 'root'@'localhost' IDENTIFIED BY 'Password123';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;

CREATE USER IF NOT EXISTS 'root'@'127.0.0.1' IDENTIFIED BY 'Password123';
ALTER USER 'root'@'127.0.0.1' IDENTIFIED BY 'Password123';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'127.0.0.1' WITH GRANT OPTION;

ALTER USER 'root'@'%' IDENTIFIED BY 'Password123';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;
EXIT;


# Update at DB connect perl script, the direction to avoid errors that perl is providing due to conda
nano /scratch/software-phgv2/miniconda3/envs/pasa_env/opt/pasa-2.5.3/PerlLib/DB_connect.pm

#    my $dbh = DBI->connect("dbi::database=$db;host=$server", $username, $password);
# Joan: deactivated line to pass directly our DBI

# Now this should work:
mysql -h 127.0.0.1 -P 3307 -u root -pPassword123 -e "status"

# Manually create the database
mysql -h 127.0.0.1 -P 3307 -u root -pPassword123 -e "CREATE DATABASE GDB136_pasa_db CHARACTER SET latin1 COLLATE latin1_swedish_ci;"
# Latin to avoid incompatibilities of bits

mysql -h 127.0.0.1 -P 3307 -u root -pPassword123 GDB136_pasa_db < /scratch/software-phgv2/miniconda3/envs/pasa_env/opt/pasa-2.5.3/schema/cdna_alignment_mysqlschema

#Perl cant handle those big pacbio names, so we have to write a simplified database
awk '/^>/{print ">transcript_" ++i; next}{print}' PASA/mRNA_IsoSeq_merged_transcripts.fasta > PASA/mRNA_IsoSeq_merged_transcripts_simple.fasta

# apply the column size patches
mysql -h 127.0.0.1 -P 3307 -u root -pPassword123 GDB136_pasa_db <<EOF
ALTER TABLE align_link MODIFY align_acc VARCHAR(1500);
ALTER TABLE cdna_info MODIFY cdna_acc VARCHAR(1500);
ALTER TABLE asmbl_link MODIFY asmbl_acc VARCHAR(1500);
EOF

# ====================================
# Execute the pipeline
# ====================================

nohup $PASA_HOME/Launch_PASA_pipeline.pl \
  -c $PWD/PASA/alignAssembly.config \
  -R \
  -g /scratch/GDB136/new_anno/data/GDB_136.fa \
  -t $PWD/PASA/mRNA_IsoSeq_merged_transcripts_simple.fasta \
  --ALIGNERS blat,gmap \
  --CPU 32 > logs/GDB136.pasa_alignment.log 2>&1 &

#If gmapl brings problems; 
rm -rf __pasa_GDB136_pasa_db_mysql_chkpts/
rm -f gmap.spliced_alignments.gff3* __pasa_gmap*
rm -rf pblat_outdir

# Go to your active Conda environment's binary directory
cd /scratch/software-phgv2/miniconda3/envs/pasa_env/bin/
mv gmapl gmapl.bak
ln -s gmap gmapl
# Jump back to your work directory
cd /scratch/GDB136/new_anno/

#If it stills complaining about safety permisions, go to the pasa perl script:
nano /scratch/software-phgv2/miniconda3/envs/pasa_env/opt/pasa-2.5.3/PerlLib/DB_connect.pm
# And set once again the line that connects with the database like this:
my $dbh = DBI->connect("dbi:mysql:database=GDB136_pasa_db;mysql_socket=/scratch/GDB136/new_anno/PASA_data/mysql.sock", "root", "Password123");

#Rerun:
nohup $PASA_HOME/Launch_PASA_pipeline.pl \
  -c $PWD/PASA/alignAssembly.config \
  -R \
  -g /scratch/GDB136/new_anno/data/GDB_136.fa \
  -t $PWD/PASA/mRNA_IsoSeq_merged_transcripts_simple.fasta \
  --ALIGNERS blat,gmap \
  --CPU 32 > logs/GDB136.pasa_alignment.log 2>&1 &

###
# Finished
###

# Thomas explained that a rerun and iterate over the results is a good idea, so going for it (using mikado out)

$PASA_HOME/scripts/Load_Current_Gene_Annotations.dbi \
  -c $PWD/PASA/alignAssembly.config \
  -g /scratch/GDB136/new_anno/data/GDB_136.fa \
  -P /scratch/GDB136/new_anno/sprot_plants_mikado_db/GDB_136.mikado_refined_prediction.run3.loci.gff3
# All mikado genes are included at the database now

nohup $PASA_HOME/Launch_PASA_pipeline.pl \
  -c $PWD/PASA/alignAssembly.config \
  -A \
  -g /scratch/GDB136/new_anno/data/GDB_136.fa \
  -t $PWD/PASA/mRNA_IsoSeq_merged_transcripts_simple.fasta \
  --CPU 32 > logs/GDB136.pasa_compare.log 2>&1 &
# -A is the tag for comparison

# If it dies, ensure proper space in disk, and relaunch
nohup $PASA_HOME/Launch_PASA_pipeline.pl \
  -c $PWD/PASA/alignAssembly.config \
  -A \
  -g /scratch/GDB136/new_anno/data/GDB_136.fa \
  -t $PWD/PASA/mRNA_IsoSeq_merged_transcripts_simple.fasta \
  --CPU 32 > logs/GDB136.pasa_compare_retry.log 2>&1 &

awk '$3 == "gene"' GDB136_pasa_db.gene_structures_post_PASA_updates.final.gff3 | wc -l
74929

####
# FINISHED PASA
#### 

# COCLA2 pipeline, set gene names and confidence level

wget https://github.com/PGSB-HMGU/cocla2/archive/refs/heads/master.zip
unzip cocla2-master.zip

# Dowload the blastdb Thomas database
wget https://hmgubox2.helmholtz-muenchen.de/public.php/dav/files/i6oxF8YFLi4enzZ/?accept=zip
unzip 'index.html?accept=zip'
rm 'index.html?accept=zip'

ls -lh cocla2-master/cocla_dbs/
total 877M
-rw-r--r-- 1 jsarria compbio  17M may 25 08:38 rexdb_trep.dmnd
-rw-r--r-- 1 jsarria compbio  16M may 25 08:38 rexdb_trep.fasta
-rw-r--r-- 1 jsarria compbio  17M may 25 08:38 uniprot_Magnoliophyta_reviewed_collapsed_170220.fasta
-rw-r--r-- 1 jsarria compbio  17M may 25 08:38 uniprot_Magnoliophyta_reviewed_collapsed_170220.fasta.dmnd
-rw-r--r-- 1 jsarria compbio 403M may 25 08:38 uniprot_Poaceae_complete_collapsed_170220.fasta
-rw-r--r-- 1 jsarria compbio 410M may 25 08:38 uniprot_Poaceae_complete_collapsed_170220.fasta.dmnd

# Now install interproscan and port-scriber

# ======= PORT-SCRIBER ===========
# we will install the binary and implement it to pananno environment
https://github.com/usadellab/prot-scriber/releases/download/v0.1.6/x86_64-unknown-linux-gnu_prot-scriber
echo $CONDA_PREFIX
mv prot-scriber $CONDA_PREFIX/bin/
# And now this should work:
prot-scriber --help
prot-scriber version 0.1.6

# ====== INTERPROSCAN ===========
perl -version
This is perl 5, version 26, subversion 2 (v5.26.2) built for x86_64-linux-thread-multi
python3 --version
Python 3.9.15
java -version
openjdk version "17.0.3-internal" 2022-04-19

mkdir my_interproscan
cd my_interproscan/

# for more info, you are following the next doc:
# https://interproscan-docs.readthedocs.io/en/v5/HowToDownload.html

wget https://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.76-107.0/interproscan-5.76-107.0-64-bit.tar.gz
wget https://ftp.ebi.ac.uk/pub/software/unix/iprscan/5/5.76-107.0/interproscan-5.76-107.0-64-bit.tar.gz.md5

md5sum -c interproscan-5.76-107.0-64-bit.tar.gz.md5
# If its ok, download is succesfull

