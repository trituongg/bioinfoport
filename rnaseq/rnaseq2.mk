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

# GTF annotation file used for featureCounts. Override this if your GTF
# doesn't share the REF basename (e.g. Ensembl downloads rarely do).
GTF ?= $(REF:.fa=.gtf)

# The directory that holds the index.
IDX_DIR = $(dir ${REF})/idx

# The name of the index
IDX ?= ${IDX_DIR}/$(notdir ${REF})

# A file in the index directory.
IDX_FILE ?= ${IDX}.1.ht2

# The alignment file.
BAM ?= bam/hisat2.bam

IS_PAIRED ?= $(if ${R2},true,false)

# Per-sample output paths, keyed by SM, so that running this Makefile in
# parallel across many samples (e.g. via `parallel` over a list of SRR
# accessions) never has two jobs write to the same file.
WIGGLE_DIR = wiggle
WIGGLE_FILE ?= ${WIGGLE_DIR}/${SM}.bedgraph

COUNT_DIR = counts
COUNT_FILE ?= ${COUNT_DIR}/${SM}_gene_counts.csv

# Combined multi-sample count matrix, built from every BAM in BAM_DIR.
# Run this once, after every sample has been aligned, before running stats.
BAM_DIR = bam
ALL_BAMS = $(wildcard ${BAM_DIR}/*.bam)
COMBINED_COUNTS_TXT = ${COUNT_DIR}/all_counts.txt
COMBINED_COUNTS = ${COUNT_DIR}/all_counts.csv

STATS_DIR = stats

DESIGN_FILE = design.csv

# Column in DESIGN_FILE holding the condition/group labels (e.g. "treatment").
FACTOR_NAME ?= group

# FDR cutoff for including a gene in the heatmap.
MIN_FDR ?= 0.05
#=========================================

#=========================================
#help message
help:
> @echo "Usage: make [target] [options] IS_PAIRED=<true|false> NCPU=<number> HISAT2_FLAGS='<flags>' ID=<id> SM=<sample> LB=<library> PL=<platform> R1=<read1> R2=<read2> REF=<reference> BAM=<alignment_file>"
> @echo "Targets:"
> @echo "  all: Run index, hisat2, wiggle, count for one sample (does NOT include stats -- run that once, separately, after all samples are counted)."
> @echo "  hisat2: Align reads to the reference genome using HISAT2."
> @echo "  index: Build the HISAT2 index for the reference genome."
> @echo "  count : Count reads per gene using featureCounts (per-sample output, keyed by SM)."
> @echo "  wiggle: Generate wiggle files from the alignment (per-sample output, keyed by SM)."
> @echo "  combine: Run featureCounts once across every BAM in BAM_DIR and format into counts/all_counts.csv. Run this once after all samples are aligned."
> @echo "  stats : Per-sample edgeR/PCA/heatmap (keyed by SM) -- NOT statistically meaningful, single sample only."
> @echo "  stats-all: Real multi-sample edgeR/PCA/heatmap over counts/all_counts.csv. Run 'combine' first."
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
> @echo "  GTF=<annotation>: Set the GTF annotation file (default: REF with .fa replaced by .gtf)."
> @echo "  BAM=<alignment_file>: Set the alignment file (default: bam/hisat2.bam)."
> @echo "  DESIGN_FILE=<design_file>: Set the design file (default: design.csv)."
> @echo "  FACTOR_NAME=<column>: Column in DESIGN_FILE holding the condition/group labels used by edgeR/PCA/heatmap (default: group)."
> @echo "  MIN_FDR=<value>: FDR cutoff for including a gene in the heatmap (default: 0.05)."
> @echo "  WIGGLE_FILE=<file>: Override the per-sample wiggle output (default: wiggle/\$${SM}.bedgraph)."
> @echo "  COUNT_FILE=<file>: Override the per-sample count output (default: counts/\$${SM}_gene_counts.csv)."
#=========================================

all: index hisat2 wiggle count
.PHONY: all

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

wiggle: $(WIGGLE_FILE)
.PHONY: wiggle

$(WIGGLE_FILE): $(BAM)
> @echo "Generating wiggle file for $(SM) from alignment $(BAM)..."
> mkdir -p $(WIGGLE_DIR)
> samtools sort -n $(BAM) | bedtools genomecov -bg -split -ibam - > $(WIGGLE_FILE)

count: $(COUNT_FILE)
.PHONY: count

$(COUNT_FILE): $(BAM)
> @echo "Counting reads per gene for $(SM) using featureCounts..."
> mkdir -p $(COUNT_DIR)
> if [ "$(IS_PAIRED)" = "true" ]; then \
>   featureCounts -T $(NCPU) -p --countReadPairs -a $(GTF) -o $(COUNT_FILE) $(BAM); \
> else \
>   featureCounts -T $(NCPU) -a $(GTF) -o $(COUNT_FILE) $(BAM); \
> fi

combine: $(COMBINED_COUNTS)
.PHONY: combine

$(COMBINED_COUNTS_TXT): $(ALL_BAMS)
> @echo "Counting reads per gene across all BAMs in $(BAM_DIR)..."
> mkdir -p $(COUNT_DIR)
> if [ "$(IS_PAIRED)" = "true" ]; then \
>   featureCounts -T $(NCPU) -p --countReadPairs -a $(GTF) -o $(COMBINED_COUNTS_TXT) $(ALL_BAMS); \
> else \
>   featureCounts -T $(NCPU) -a $(GTF) -o $(COMBINED_COUNTS_TXT) $(ALL_BAMS); \
> fi

$(COMBINED_COUNTS): $(COMBINED_COUNTS_TXT)
> @echo "Formatting combined counts into $(COMBINED_COUNTS)..."
> micromamba run -n stats Rscript src/r/format_featurecounts.r -c $(COMBINED_COUNTS_TXT) -o $(COMBINED_COUNTS)

stats-all: $(COMBINED_COUNTS)
> @echo "Generating statistics across all samples in $(COMBINED_COUNTS)..."
> mkdir -p $(STATS_DIR)
> micromamba run -n stats Rscript src/r/edger.r -f $(FACTOR_NAME) -d $(DESIGN_FILE) -c $(COMBINED_COUNTS) -o $(STATS_DIR)/all_edger.csv
> micromamba run -n stats Rscript src/r/plot_pca.r -f $(FACTOR_NAME) -d $(DESIGN_FILE) -c $(COMBINED_COUNTS) -o $(STATS_DIR)/all_pca.pdf
> micromamba run -n stats Rscript src/r/plot_heatmap.r -f $(FACTOR_NAME) -q $(MIN_FDR) -d $(DESIGN_FILE) -c $(COMBINED_COUNTS) -o $(STATS_DIR)/all_heatmap.pdf
.PHONY: stats-all

stats: $(COUNT_FILE)
> @echo "Generating statistics for $(SM) from count data..."
> mkdir -p $(STATS_DIR)
> micromamba run -n stats Rscript src/r/edger.r -f $(FACTOR_NAME) -d $(DESIGN_FILE) -c $(COUNT_FILE) -o $(STATS_DIR)/$(SM)_edger.csv
> micromamba run -n stats Rscript src/r/plot_pca.r -f $(FACTOR_NAME) -d $(DESIGN_FILE) -c $(COUNT_FILE) -o $(STATS_DIR)/$(SM)_pca.pdf
> micromamba run -n stats Rscript src/r/plot_heatmap.r -f $(FACTOR_NAME) -q $(MIN_FDR) -d $(DESIGN_FILE) -c $(COUNT_FILE) -o $(STATS_DIR)/$(SM)_heatmap.pdf
.PHONY: stats(bioinfo)