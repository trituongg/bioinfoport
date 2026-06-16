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

# We are going to code a makefile only for getting bam and outputting vcf no more

# Define variables for input and output files we still want input
BAM_FILE =? input.bam
VCF_FILE =? output.vcf.gz
REF_FILE =? reference.fa
THREADS  =? 1

#=========================================
# help display
help:
>@echo "Usage: make [target] BAM_FILE=input.bam VCF_FILE=output.vcf.gz REF_FILE=reference.fa THREADS=4"
>@echo "Targets:"
>@echo "  all       - Generate VCF from BAM file (default)"
>@echo "  clean     - Remove generated VCF file"
>@echo "  help      - Display this help message"
#=========================================

all: $(VCF_FILE)

$(VCF_FILE): $(BAM_FILE)
> echo "Running VCF pipeline..."
> bcftools mpileup -f $(REF_FILE) --threads $(THREADS) $< | \
> bcftools call -mv -Ou | \
> bcftools norm -f $(REF_FILE) -Ou | \
> bcftools sort -Oz -o $@
> bcftools index $@
> echo "Done: $@"

# Clean target to remove generated VCF file
clean:
> echo "Cleaning up generated files..."
> rm -f $(VCF_FILE) $(VCF_FILE).gz $(VCF_FILE).norm.gz $(VCF_FILE).sorted.gz
> echo "Cleanup complete."	

