# TOOLBOX
## PHILOSOPHY OF MAKEFILES

+ Each makefile wraps a single bioinformatics tool.

+ Each makefile has the same user interface

+ Each makefile has the same parameter naming conventions.

## SNAKEMAKE AND NEXTFLOW?

Needlessly complicated and are basically "black boxes" 

Experts made program made for experts. 

## WHAT TO DO 

You can try out the Biostar handbook toolbox to learn for yourself. Then 

## LET'S TRY THE TOOLBOX 

``` URL=https://hgdownload.soe.ucsc.edu/goldenPath/hg38/chromosomes/chr13.fa.gz``` = SETTING THE URL

```REF=refs/chr13.fa.gz``` give the file name

```make run -f run/curl.mk URL=${URL} REF=${REF}``` get the file

```make -f run/bgzip.mk FILE=${REF} run``` rezip it

```make -f run/bwa.mk REF=${REF} index```

```
 2072  N=100000
 2073  R1=reads/sample1_pair1.fastq
 2074  make -f run/sra.mk         SRR=SRR17653520         N=${N}         R1=${R1}         run
 2075  ls
 2076  # The path to the BAM file
 2077  BAM=bam/sample1.bam
 2078  # Align the reads to the reference genome
 2079  make -f run/bwa.mk         REF=${REF}         R1=${R1}         BAM=${BAM}         align
 2080  make -f run/coverage.mk         BAM=${BAM}         REF=${REF}         run
 ```

 Basically download 100k reads and then align and get bw. 

 With these makefiles we can easily do our job. It is best practice to use them as such. No more "black boxes"

 ## DOCUMENTING THE TOOLBOX

 It is best practice to document them well