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
