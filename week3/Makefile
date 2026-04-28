# Initialize Makefile with best practices for reproducibility and error handling


#=========================================
SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
endif
.RECIPEPREFIX = >
#=========================================


# =========================================
# BEFORE WE START, WORKFLOW ORDER:
# 1. download_refseq
# 2. download_srr
# 3. index
# 4. align
# 5. generate BAM index (.bai)
# =========================================


#=========================================
# TASK
# - [ ] Create a `Makefile` from the original bash script  
# - [ ] Add rule to download genome  
#- [ ] Add rule to download sequencing reads from SRA  
# SRR sample used: ```SRR1972883```
# NCBI RefSeq assembly: ```GCF_000848505.1``` NCBI Assembly ID for Ebola virus/H.sapiens-tc/COD/1976/Yambuku-Mayinga
# =========================================


# =========================================
#DEFINE GENOME HERE AND ALLOW INPUT FROM COMMAND LINE
SRR_ID ?= SRR1972883
REFSEQ_ID ?= GCF_000848505.1
# =========================================


# =========================================
# DEFINE and allow input from command line:
# - reference genome FASTA filename
# - FASTQ filenames
# - SAM filename
# - sorted BAM filename
# - BAM index filename (.bai)
#DEFINE THE FILES HERE 
REFSEQ_FASTA := reference/$(REFSEQ_ID).fna
REFSEQ_INDEX := reference/$(REFSEQ_ID).fna.fai
READS_DONE := reads/$(SRR_ID).done # this is only a marker file
# READS ARE PAIRED END SO TWO FILES
R1 := reads/$(SRR_ID)_1.fastq
R2 := reads/$(SRR_ID)_2.fastq
ALIGNMENT_SAM := alignment/$(SRR_ID).sam
ALIGNMENT_BAM := alignment/$(SRR_ID).bam
ALIGNMENT_BAM_INDEX := alignment/$(SRR_ID).bam.bai
# =========================================


# =========================================
# CREATE DIRECTORIES
# - reference/     for genome FASTA + indexes
# - reads/         for FASTQ files
# - alignment/     for SAM/BAM outputs
# REMEMBER THAT OUR DELIM IS > SO USE IT TO NOT GET  *** missing separator.  Stop. ERROR
dirs: 
> mkdir -p reference reads alignment
.PHONY: dirs
# =========================================


# =========================================
# Whenever someone uses this makefile it will print out that you can input the SRR and RefSeq (using a .PHONY) IDs from the command line, and it will show the default values that will be used if you don't specify them.
help:
> @echo "Usage: make [target] [SRR_ID=SRRxxxxxxx] [REFSEQ_ID=GCF_xxxxxxx]"
> @echo "Default SRR_ID: $(SRR_ID)"
> @echo "Default REFSEQ_ID: $(REFSEQ_ID)"
> @echo ""
> @echo "Required tools: datasets, fasterq-dump, bwa, samtools, preferably the bioinfio environment"
> @echo "Targets:"
> @echo "  download_refseq - downloads the reference genome FASTA"
> @echo "  download_srr    - downloads the sequencing reads from SRA"
> @echo "  index           - creates index for the reference genome"
> @echo "  align           - aligns reads to the reference genome"
> @echo "  index_bam       - generates BAM index (.bai)"
> @echo "  dirs            - creates necessary directories"
> @echo "  build           - runs the full workflow (download, index, align, index_bam)"
.PHONY: help
# =========================================


# =========================================
#building the entire workflow in one command
build: download_refseq download_srr index align index_bam
.PHONY: build
# =========================================


# =========================================
# Download the reference genome FASTA file using the RefSeq ID from NCBI using datasets
# datasets download genome accession GCF_000848505.1 
#--include genome,protein,gff3,cds,seq-report,rna
# index the file too using samtools faidx
# Since we are downloading a zip file, we need to unzip it and find the fasta file inside and copy it to the reference directory with the name $(REFSEQ_ID).fna
download_refseq: $(REFSEQ_FASTA)
$(REFSEQ_FASTA):
> datasets download genome accession $(REFSEQ_ID) --include genome,protein,gff3,cds,seq-report,rna --filename reference/$(REFSEQ_ID).zip
> unzip -o reference/$(REFSEQ_ID).zip -d reference/
> find reference/ncbi_dataset/data -name "*.fna" -exec cp {} $@ \;
> rm reference/$(REFSEQ_ID).zip
.PHONY: download_refseq
# =========================================


# =========================================
## make the index here and find the fasta file 
# basically means that it will search for any file with the .fna extension in the reference/ncbi_dataset/data directory and take the first one it finds. This is useful because the exact filename may not be known in advance, especially if it includes version numbers or other details.
# if there is no fasta file it will print an error 
# indexing the fasta file using bwa is needed because bwa requires it own index format, but samtools faidx creates a .fai index which is also needed for alignment and other downstream analyses. So we need both indexes for different purposes.
REFSEQ_INDEX := \
reference/$(REFSEQ_ID).fna.fai \
reference/$(REFSEQ_ID).fna.amb \
reference/$(REFSEQ_ID).fna.ann \
reference/$(REFSEQ_ID).fna.bwt \
reference/$(REFSEQ_ID).fna.pac \
reference/$(REFSEQ_ID).fna.sa
index: $(REFSEQ_INDEX)
$(REFSEQ_INDEX): $(REFSEQ_FASTA)
> samtools faidx $<
> bwa index $<
.PHONY: index
# =========================================


# =========================================
# Download the sequencing reads from SRA using the SRR ID
# Use fasterq dump and they are paired ends so split ends
# SRR1972883_1.fastq and SRR1972883_2.fastq
# no need for compression since we are just going to align them and bwa doesn't require gzipped files
# since we declared a marker file earlier, let's use it here
download_srr: $(READS_DONE)
$(READS_DONE):
> fasterq-dump $(SRR_ID) --split-files -O reads/
> touch $@
.PHONY: download_srr
# =========================================


# =========================================
# Recall that we defined read 1 and read 2 as variables earlier, so we can use those here.
# And require the reference index 
align: $(ALIGNMENT_BAM)
$(ALIGNMENT_SAM): $(R1) $(R2) $(REFSEQ_FASTA)
> bwa mem $(REFSEQ_FASTA) $(R1) $(R2) > $@
$(ALIGNMENT_BAM): $(ALIGNMENT_SAM)
> samtools sort -o $@ $<
.PHONY: align
# =========================================


# =========================================
# Index BAM file to create .bai index using samtools index
# since we probably don't know where the fna file is it's best to index by finding the file
index_bam: $(ALIGNMENT_BAM_INDEX)
$(ALIGNMENT_BAM_INDEX): $(ALIGNMENT_BAM)
> samtools index $<
.PHONY: index_bam
# ========================================







