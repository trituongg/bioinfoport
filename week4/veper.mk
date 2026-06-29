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
#Makefile default variables for VEP calling
INPUT?=/home/tristuowngf/week10/VEP_RUN/ebola/sample1/vcf/sample1.vcf.gz
OUTPUT?=/home/tristuowngf/week10/VEP_RUN/ebola_output/sample1.vep.vcf
GFF?=/home/tristuowngf/week10/VEP_RUN/gff/Ebola.Mayinga.1976.gff.gz
FASTA?=/home/tristuowngf/week10/VEP_RUN/ebola/reference/GCF_000848505.1.fna
#=========================================

#=========================================
#help message
help:
> @echo "Usage: make -f veper.mk [target] INPUT=<input_vcf> OUTPUT=<output_vcf> GFF=<gff_file> FASTA=<fasta_file>"
> @echo "Targets:"
> @echo "  help     - Display this help message"
> @echo "  vep      - Run VEP on the input VCF file"
#=========================================

#=========================================
#VEP command
vep:
> mkdir -p $(dir $(OUTPUT))
> micromamba run -n vep vep \
> -i $(INPUT) \
> -o $(OUTPUT) \
> --gff $(GFF) \
> --fasta $(FASTA) \
> --vcf \
> --everything \
> --verbose
#=========================================

									

