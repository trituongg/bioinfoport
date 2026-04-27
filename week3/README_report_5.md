# SHORT READ ALIGNMENTS

## CHOOSING THE RIGHT TOOL 

![description](images_week3/Screenshot%202026-04-27%20131239.png)

## INDEXING
Basically using a lookup table

```bwa index refs/genome.fa``` (optional for minimap2)

## ALIGNMENT TEMPLATE 
### bwa
```
# Index the reference genome (only needs to be done once)
bwa index ${REF} 

# Align the paired-end reads
bwa mem ${REF} ${R1} ${R2} > ${SAM}

# Sort the SAM file to BAM
cat ${SAM} | samtools sort > ${BAM}

# Index the BAM file
samtools index ${BAM}
```

### minimap2

```
# Align single end reads with minimap2.
minimap2 --MD -ax sr ${REF} ${R1} | \
         samtools sort > ${BAM}
```
### bowtie2
Very flexible
```
# Index the genome
bowtie2-build ${REF} ${REF}  # Build the Bowtie2 index

# Align the reads
bowtie2 -x ${REF} -1 ${R1} -2 ${R2} > ${SAM} 
```


## WHICH TO USE??
Depends and you can fine tune tools to get the results you want

## ALIGNMENT VS MAPPING
Quote 
```
Mapping

A mapping is a region where a read sequence is placed.
A mapping is regarded to be correct if it overlaps the true region.
Alignment

An alignment is the detailed placement of each base in a read.
An alignment is regarded to be correct if each base is placed correctly.
```

## CHECKLIST
```
Alignment algorithm: global, local, or semi-global?
Can the aligner filter alignments based on external parameters?
Can the aligner report more than one alignment per query?
How will the aligner handle INDELs (insertions/deletions)?
Can the aligner skip (or splice) over intronic regions?
Will the aligner find chimeric alignments?
```

## THE BAM/SAM FORMAT
```SAM``` :(Sequence Alignment/Map) and ```BAM``` is evil binary brother. 

There are 11 columns in a bam file
```
QNAME - Query (read) name
FLAG - Bitwise flag with alignment details
RNAME - Reference sequence name
POS - 1-based leftmost mapping position
MAPQ - Mapping quality score
CIGAR - Compact alignment representation
RNEXT - Mate/next read reference name
PNEXT - Mate/next read position
TLEN - Observed template length
SEQ - Segment sequence
QUAL - Base quality scores
TAGS - Optional fields for additional information
```

```samtools``` = master of this.  (also ```bedtools``` and ```picard```)

```
# Display available samtools operations
samtools

# Download a remote BAM file
wget https://genome.ucsc.edu/goldenPath/help/examples/bamExample.bam

# Index the BAM file
samtools index bamExample.bam

# Print BAM file statistics
samtools flagstat bamExample.bam
```

IMPORTANT: THEY CAN BE VIEW IN IGV

# ACTUAL REPORT 

## Assignment Checklist

### 1. Makefile Setup
- [ ] Create a `Makefile` from the original bash script  
- [ ] Add rule to download genome  
- [ ] Add rule to download sequencing reads from SRA  

### 2. Documentation
- [ ] Write `README.md` explaining how to use the Makefile  
- [ ] Include example commands (e.g., `make`, `make align`)  
- [ ] Describe file structure and outputs  

### 3. Makefile Targets
- [ ] `index` → Index the reference genome  
- [ ] `align` → Align reads and produce sorted BAM  
- [ ] Generate BAM index (`.bai`)  

### 4. Visualization
- [ ] Visualize BAM for simulated reads  
- [ ] Visualize BAM for SRA reads  
- [ ] Include screenshots or describe observations  

### 5. Alignment Statistics
- [ ] Generate alignment statistics (e.g., `samtools flagstat`)  
- [ ] Report percentage of reads aligned  
- [ ] Calculate expected average coverage  
- [ ] Calculate observed average coverage  
- [ ] Estimate coverage variation across genome  
- [ ] Include a visualization (coverage plot or IGV screenshot)  

### 6. Final Checks
- [ ] All commands run successfully via Makefile  
- [ ] Repository is organized and reproducible  
- [ ] GitHub link is ready for submission  