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

# Basically the same as the orginal Makefile but expanded and uses a different species.

# =========================================
#DEFINE GENOME HERE AND ALLOW INPUT FROM COMMAND LINE
SRR_ID ?= SRR1972739
REFSEQ_ID ?= GCF_000848505.1
THREADS ?= $(shell nproc)
SAMPLE_NAME ?= sample1
PRJ_ACC ?= PRJNA257197 
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
READS_DONE := $(SAMPLE_NAME)/reads/$(SRR_ID).done # this is only a marker file
# READS ARE PAIRED END SO TWO FILES
R1_GZ := $(SAMPLE_NAME)/reads/$(SRR_ID)_1.fastq.gz
R2_GZ := $(SAMPLE_NAME)/reads/$(SRR_ID)_2.fastq.gz
# The assignment requires the alignment to have the sample name so we have to change it. 
ALIGNMENT_SAM := $(SAMPLE_NAME)/alignment/$(SAMPLE_NAME).sam
ALIGNMENT_BAM := $(SAMPLE_NAME)/alignment/$(SAMPLE_NAME).bam
ALIGNMENT_BAM_ONT := $(SAMPLE_NAME)/alignment/$(SAMPLE_NAME)_ONT.bam
ALIGNMENT_BAM_INDEX := $(SAMPLE_NAME)/alignment/$(SAMPLE_NAME).bam.bai
USE_SRA ?= no 
READ_CEILING ?= 1000000 # this is a variable that allows us to limit the number of reads downloaded from SRA for testing purposes. If set to 0, it will download all reads. If set to a positive integer, it will download only that many reads. This is useful for testing the workflow on a smaller dataset before running it on the full dataset.
# this is like a switch that allows us to choose whether to use the SRA toolkit or not. If we set it to yes, it will use the SRA toolkit to download the reads, if we set it to no, it will assume that the reads are already in the reads/ directory and will skip the download step. This is useful if we want to use our own data instead of downloading from SRA.
# =========================================


# =========================================
# CREATE DIRECTORIES
# - reference/     for genome FASTA + indexes
# - reads/         for FASTQ files
# - alignment/     for SAM/BAM outputs
# REMEMBER THAT OUR DELIM IS > SO USE IT TO NOT GET  *** missing separator.  Stop. ERROR
# create a parent directory with the sample name we defined and then create the subdirectories inside it to keep things organized. 
dirs:
# no need for reference since we are only using 1 reference for all samples, we can just put it in the main reference directory and then link it to the sample directory if needed. This way we won't have multiple copies of the same reference genome taking up space on disk.
> mkdir -p 	$(SAMPLE_NAME)/reads \
			$(SAMPLE_NAME)/alignment
.PHONY: dirs
# =========================================


# =========================================
# Whenever someone uses this makefile it will print out that you can input the SRR and RefSeq (using a .PHONY) IDs from the command line, and it will show the default values that will be used if you don't specify them.
help:
> @echo "========================================="
> @echo "Bioinformatics Makefile Usage"
> @echo "========================================="
> @echo ""
> @echo "USAGE:"
> @echo "  make build REFSEQ_ID=GCA_xxxxx SRR_ID=SRRxxxxxx SAMPLE_NAME=sample1 USE_SRA=yes|no"
> @echo "  make align REFSEQ_ID=GCA_xxxxx SRR_ID=SRRxxxxxx SAMPLE_NAME=sample1 USE_SRA=yes|no"
> @echo "  cat design.csv | parallel -j 4 make build_multi SRR_ID={1} SAMPLE_NAME={2} REFSEQ_ID=GCA_xxxxx USE_SRA=yes"
> @echo "WORKFLOW STEPS:"
> @echo "  get_csv        - input project accession and get the design.csv file with sample names, SRR IDs"
> @echo "  build          - full pipeline (download + index + align)"
> @echo "  build_ONT      - full pipeline for ONT data (download + index + align)"
> @echo "  download_refseq- download reference genome (NCBI datasets)"
> @echo "  download_srr   - download reads from SRA (requires SRR)"
> @echo "  index          - build bwa + samtools reference indexes"
> @echo "  align          - align reads to reference genome"
> @echo "  align_ONT      - align ONT reads to reference genome (using minimap2)"
> @echo "  index_bam      - create BAM index (.bai)"
> @echo "  index_bam_ONT  - create BAM index for ONT data (.bai)"
> @echo "  bam_ONT_to_bw  - convert ONT BAM to bigwig"
> @echo "  dirs           - create necessary directories"
> @echo "  toBW           - convert BAM to bigwig"
> @echo "  stats          - generate alignment statistics using both samtools flagstats and bamtools stats"
> @echo "  ONT_stats      - generate alignment statistics for ONT data using both samtools flagstats and bamtools stats"
> @echo "  fastqc          - run FastQC on the raw reads"
> @echo ""
> @echo "  Specify threads with THREADS variable (default: all available cores)"
> @echo "  READ_LIMIT can be set to limit the number of reads downloaded (for testing)"
> @echo "  READ_CEILING can be set to limit the number of reads downloaded from SRA for testing purposes"
> @echo "========================================="
.PHONY: help
# =========================================


# =========================================
#get_csv is a WIP since NCBI server are kinda bad and not reliable 
# just print work in progress for now 
get_csv:
> @echo "Sorry, this is a WIP"
.PHONY: get_csv

# =========================================
#building the entire workflow in one command
build: dirs download_refseq download_srr fastqc index align index_bam toBW stats
.PHONY: build
# ========================================


# =========================================
# building the entire workflow for ONT data in one command
# this is just a template and would need to be modified based on the specific requirements for ONT data, such as using minimap2 for alignment instead of bwa, and adjusting the parameters for ONT reads.
build_ONT: dirs download_refseq download_srr fastqc index align_ONT index_bam_ONT bam_ONT_to_bw ONT_stats
.PHONY: build_ONT 
# ========================================


# =========================================
# Download the reference genome FASTA file using the RefSeq ID from NCBI using datasets
# datasets download genome accession GCF_000848505.1 
#--include genome,protein,gff3,cds,seq-report,rna
# index the file too using samtools faidx
# Since we are downloading a zip file, we need to unzip it and find the fasta file inside and copy it to the reference directory with the name $(REFSEQ_ID).fna
# find the fasta with .fna or .fa or .fasta extension and move it to the reference directory with the name $(REFSEQ_ID).fna which is basically REFSEQ_FASTA. 
# Since it is very inefficient to download the reference for every sample. We can make this a separate step and then just require the reference fasta file for the alignment step. This way we only download and index the reference once, and then we can reuse it for multiple samples if needed.
download_refseq: $(REFSEQ_FASTA)
$(REFSEQ_FASTA):
# Create 1 single reference directory in the main directory to store the reference genome, and then link it to the sample directory if needed. This way we won't have multiple copies of the same reference genome taking up space on disk.
> mkdir -p reference
> datasets download genome accession $(REFSEQ_ID) --include genome --filename reference/$(REFSEQ_ID).zip
> unzip -o reference/$(REFSEQ_ID).zip -d reference/
> find reference/ncbi_dataset/data -type f \( -name "*.fna" -o -name "*.fa" -o -name "*.fasta" \) -exec cp {} reference/$(REFSEQ_ID).fna \;
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
# this code is inspired by biostar handbook make file to download only segment
download_srr:
ifeq ($(USE_SRA),yes)

> mkdir -p $(SAMPLE_NAME)/reads

# Step 1: download full reads
> fasterq-dump $(SRR_ID) \
    --split-files \
    --outdir $(SAMPLE_NAME)/reads \
    --threads $(THREADS)

# Step 2: enforce READ_CEILING properly (if not ALL)
ifeq ($(READ_CEILING),ALL)
> @echo "Downloading full dataset"
else
> seqtk sample -s100 $(SAMPLE_NAME)/reads/$(SRR_ID)_1.fastq $(READ_CEILING) > $(SAMPLE_NAME)/reads/tmp_1.fastq
> seqtk sample -s100 $(SAMPLE_NAME)/reads/$(SRR_ID)_2.fastq $(READ_CEILING) > $(SAMPLE_NAME)/reads/tmp_2.fastq
> mv -f $(SAMPLE_NAME)/reads/tmp_1.fastq $(SAMPLE_NAME)/reads/$(SRR_ID)_1.fastq
> mv -f $(SAMPLE_NAME)/reads/tmp_2.fastq $(SAMPLE_NAME)/reads/$(SRR_ID)_2.fastq
endif

# Step 3: compress
> gzip -f $(SAMPLE_NAME)/reads/$(SRR_ID)_1.fastq
> gzip -f $(SAMPLE_NAME)/reads/$(SRR_ID)_2.fastq

# Step 4: marker file
> touch $(READS_DONE)

else
> @echo "Skipping SRA download (using local FASTQs)"
endif

.PHONY: download_srr
# =========================================


# =========================================
# fastqc on the raw reads to check the quality before alignment
fastqc: $(R1_GZ) $(R2_GZ)
$(R1_GZ) $(R2_GZ): $(READS_DONE) # make sure to run this after the reads have been downloaded
> fastqc -t $(THREADS) $^ -o $(SAMPLE_NAME)/reads/
.PHONY: fastqc	
# =========================================


# =========================================
# Recall that we defined read 1 and read 2 as variables earlier, so we can use those here.
# And require the reference index 
# converting to SAM takes a lot of disk space
# Let's convert to BAM and sort on the fly to save space. We can do this by piping the output of bwa mem directly into samtools sort. This way we won't have an intermediate SAM file taking up space on disk. The command would look like this:
# bwa mem -t $(THREADS) $(SAMPLE_NAME)/reference/$(REFSEQ_ID).fna $(SAMPLE_NAME)/reads/$(SRR_ID)_1.fastq $(SAMPLE_NAME)/reads/$(SRR_ID)_2.fastq | samtools sort -o $(SAMPLE_NAME)/alignment/$(SRR_ID).bam
# since this step is long we can also add a progress bar using pv (pipe viewer) to monitor the progress of the alignment. The command would look like this:
# bwa mem -t $(THREADS) $(SAMPLE_NAME)/reference/$(REFSEQ_ID).fna $(SAMPLE_NAME)/reads/$(SRR_ID)_1.fastq $(SAMPLE_NAME)/reads/$(SRR_ID)_2.fastq | pv | samtools sort -@ $(THREADS) -o $(SAMPLE_NAME)/alignment/$(SRR_ID).bam
align: $(ALIGNMENT_BAM)
$(ALIGNMENT_BAM): $(R1_GZ) $(R2_GZ) $(REFSEQ_FASTA)
> bwa mem -t $(THREADS) $(REFSEQ_FASTA) $(R1_GZ) $(R2_GZ) | pv | samtools sort -@ $(THREADS) -o $@
.PHONY: align
# =========================================

# =========================================
# This is just a template for ONT data and would need to be modified based on the specific requirements for ONT data, such as using minimap2 for alignment instead of bwa, and adjusting the parameters for ONT reads.
# The reason why we declared BAM_ONT as a variable earlier is so that we can use it here and it will be clear that this is the BAM file for ONT data. This way we can keep our files organized and avoid confusion between the different types of data.
# minimap 2 can accept gzipped FASTQ files directly, so we can use the gzipped versions of the reads here as well. 
align_ONT: $(ALIGNMENT_BAM_ONT)
$(ALIGNMENT_BAM_ONT): $(R1_GZ) $(REFSEQ_FASTA)
> minimap2 -t $(THREADS) -ax map-ont $(REFSEQ_FASTA) $(R1_GZ) | pv | samtools sort -@ $(THREADS) -o $@
.PHONY: align_ONT 
# =========================================


# =========================================
# Index BAM file to create .bai index using samtools index
# since we probably don't know where the fna file is it's best to index by finding the file
index_bam: $(ALIGNMENT_BAM_INDEX)
$(ALIGNMENT_BAM_INDEX): $(ALIGNMENT_BAM)
> samtools index $<
.PHONY: index_bam
# ========================================

# ========================================
# Index BAM file for ONT data to create .bai index using samtools index
index_bam_ONT: $(ALIGNMENT_BAM_ONT).bai
$(ALIGNMENT_BAM_ONT).bai: $(ALIGNMENT_BAM_ONT)
> samtools index $<
.PHONY: index_bam_ONT
# ========================================



# ========================================
# Convert BAM to bigwig using bamCoverage from deepTools using this template:
# micromamba run -n deep bamCoverage   -b SRR1972739_mapped.bam  -o SRR1972739_mapped.bw
# we now change it to the new name scheming
toBW: $(SAMPLE_NAME)/alignment/$(SAMPLE_NAME).bw
$(SAMPLE_NAME)/alignment/$(SAMPLE_NAME).bw: $(ALIGNMENT_BAM)
> micromamba run -n deep bamCoverage -b $< -o $@ --numberOfProcessors $(THREADS)
.PHONY: toBW
# =========================================



# =========================================
# Convert ONT BAM to bigwig using bamCoverage from deepTools
bam_ONT_to_bw: $(SAMPLE_NAME)/alignment/$(SAMPLE_NAME)_ONT.bw
$(SAMPLE_NAME)/alignment/$(SAMPLE_NAME)_ONT.bw: $(ALIGNMENT_BAM_ONT)
> micromamba run -n deep bamCoverage -b $< -o $@ --numberOfProcessors $(THREADS)
.PHONY: bam_ONT_to_bw	
# ========================================


# =========================================
# Generate alignment statistics using both samtools flagstat and bamtools stats
stats: samtools_stats.txt bamtools_stats.txt
samtools_stats.txt: $(ALIGNMENT_BAM)
> samtools flagstat $< > $@
bamtools_stats.txt: $(ALIGNMENT_BAM)
> bamtools stats -in $< > $@
.PHONY: stats
# =========================================


# =========================================
# Generate alignment statistics for ONT data using both samtools flagstats and bamtools stats
ONT_stats: samtools_stats_ONT.txt bamtools_stats_ONT.txt
samtools_stats_ONT.txt: $(ALIGNMENT_BAM_ONT)
> samtools flagstat $< > $@
bamtools_stats_ONT.txt: $(ALIGNMENT_BAM_ONT)
> bamtools stats -in $< > $@
.PHONY: ONT_stats
# =========================================

