#Makefile safety
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

#=========================================
#variables for rnaseq
# Number of CPUS
NCPU ?= 2

# Additional flags to pass to HISAT.
HISAT2_FLAGS ?= --threads ${NCPU} --sensitive

# Read group information.
ID ?= run1
SM ?= sample1
LB ?= library1
PL ?= ILLUMINA

# Set the read groups.
RG ?= --rg-id ${ID} --rg SM:${SM} --rg LB:${LB} --rg PL:${PL}

# First in pair.
R1 ?= reads/read1.fq

# Second in pair.
R2 ?=

# The reference genome.
REF ?= refs/genome.fa

# The directory that holds the index.
IDX_DIR = $(dir ${REF})/idx

# The name of the index
IDX ?= ${IDX_DIR}/$(notdir ${REF})

# A file in the index directory.
IDX_FILE ?= ${IDX}.1.ht2

# The alignment file.
BAM ?= bam/hisat2.bam

IS_PAIRED ?= $(if ${R2},true,false)
#=========================================

#=========================================
#help message
help:
> @echo "Usage: make [target] [options] IS_PAIRED=<true|false> NCPU=<number> HISAT2_FLAGS='<flags>' ID=<id> SM=<sample> LB=<library> PL=<platform> R1=<read1> R2=<read2> REF=<reference> BAM=<alignment_file>"
> @echo "Targets:"
> @echo "  all: Run the full RNA-seq pipeline."
> @echo "  hisat2: Align reads to the reference genome using HISAT2."
> @echo "  index: Build the HISAT2 index for the reference genome."
> @echo "  wiggle: Generate wiggle files from the alignment."
> @echo "  help: Show this help message."
> @echo "Options:"
> @echo "  IS_PAIRED=<true|false>: Specify if the reads are paired-end (default: $(if ${R2},true,false))."
> @echo "  NCPU=<number>: Set the number of CPUs to use (default: 2)."
> @echo "  HISAT2_FLAGS='<flags>': Additional flags to pass to HISAT2 (default: --threads ${NCPU} --sensitive)."
> @echo "  ID=<id>: Set the read group ID (default: run1)."
> @echo "  SM=<sample>: Set the sample name (default: sample1)."
> @echo "  LB=<library>: Set the library name (default: library1)."
> @echo "  PL=<platform>: Set the platform (default: ILLUMINA)."
> @echo "  R1=<read1>: Set the first read file (default: reads/read1.fq)."
> @echo "  R2=<read2>: Set the second read file (default: reads/read2.fq)."
> @echo "  REF=<reference>: Set the reference genome file (default: refs/genome.fa)."
> @echo "  BAM=<alignment_file>: Set the alignment file (default: bam/hisat2.bam)."
#=========================================

all: index hisat2 wiggle

#Reads and ref must exist
$(R1):
> @echo "Error: Read file $(R1) does not exist."
> @exit 1

#ref2 can be blank only if is_paired is false
> if eq ($(IS_PAIRED),true)
$(R2):
> @echo "Error: Read file $(R2) does not exist."
> @exit 1
> endif

$(REF):
> @echo "Error: Reference file $(REF) does not exist."
> @exit 1

index: $(IDX_FILE)
.PHONY: index

$(IDX_FILE): $(REF)
> @echo "Building HISAT2 index for reference genome $(REF)..."
> mkdir -p $(IDX_DIR)
> hisat2-build $(REF) $(IDX)

hisat2: $(BAM)
.PHONY: hisat2

$(BAM): $(R1) $(R2) $(IDX_FILE)
> @echo "Aligning reads to reference genome $(REF) using HISAT2..."
> mkdir -p $(dir $(BAM))
> if [ "$(IS_PAIRED)" = "true" ]; then \
>   hisat2 $(HISAT2_FLAGS) $(RG) -x $(IDX) -1 $(R1) -2 $(R2) | samtools view -bS - > $(BAM); \
> else \
>   hisat2 $(HISAT2_FLAGS) $(RG) -x $(IDX) -U $(R1) | samtools view -bS - > $(BAM); \
> fi

wiggle: $(BAM)
> @echo "Generating wiggle files from alignment $(BAM)..."
> mkdir -p wiggle
> samtools sort -n $(BAM) | bedtools genomecov -bg -split -ibam - > wiggle/coverage.bedgraph
.PHONY: wiggle