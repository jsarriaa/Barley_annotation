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
