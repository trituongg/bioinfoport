# AUTOMATING 

## FOREWORD

My previous make file [Makefile2](week3/Makefile_2.mk) can already automate a single ```fastq``` sample input. For this report, I will use parallel outside the Makefile and just loop over each one. I will make it so that the makefile will create a specific directory for that sample name. In addition, I will make an option to automate making the design.csv as well. And an option to limit the amoutn of reads downloaded (inspired by Biostar's sra.mk file in ```bio code```)

- [x] Create and add `Makefile` to repository

So called ```Makefile_3.mk```

- [x] Create and add `README.md`

Here 

- [x] Create and add `design.csv`

Done

- [x] Identify SRR numbers and corresponding sample names
- [x] Map SRR → sample names in `design.csv`
- [x] Modify Makefile to generate BAM files named after sample names
- [x] Ensure pipeline produces:
  - [x] FASTQ files
  - [x] FASTQC reports
  - [x] BAM alignment files
  - [x] coverage files (BW format)
  - [x] alignment statistics report (samtools/bamtools)
- [x] Run Makefile on multiple samples using GNU parallel (≥10 samples)
- [x] Verify outputs are correctly named per sample
- [x] Write `README.md` with full run instructions
- [x] Confirm repository structure is clean and reproducible
- [x] Submit GitHub repository link

We can use ```ls -R G*``` to see the results of our run 

```
ls -R G*
G5570.1:
alignment  reads

G5570.1/alignment:
G5570.1.bam  G5570.1.bam.bai  G5570.1.bw

G5570.1/reads:
SRR1972886.done  SRR1972886.done_fastqc.html  SRR1972886.done_fastqc.zip  SRR1972886_1.fastq.gz  SRR1972886_2.fastq.gz

G5640.1:
alignment  reads

G5640.1/alignment:
G5640.1.bam  G5640.1.bam.bai  G5640.1.bw

G5640.1/reads:
SRR1972900.done  SRR1972900.done_fastqc.html  SRR1972900.done_fastqc.zip  SRR1972900_1.fastq.gz  SRR1972900_2.fastq.gz

G5644.1:
alignment  reads

G5644.1/alignment:
G5644.1.bam  G5644.1.bam.bai  G5644.1.bw

G5644.1/reads:
SRR1972901.done  SRR1972901.done_fastqc.html  SRR1972901.done_fastqc.zip  SRR1972901_1.fastq.gz  SRR1972901_2.fastq.gz

G5735.2:
alignment  reads

G5735.2/alignment:
G5735.2.bam  G5735.2.bam.bai  G5735.2.bw

G5735.2/reads:
SRR1972920.done  SRR1972920.done_fastqc.html  SRR1972920.done_fastqc.zip  SRR1972920_1.fastq.gz  SRR1972920_2.fastq.gz

G5898.1:
alignment  reads

G5898.1/alignment:
G5898.1.bam  G5898.1.bam.bai  G5898.1.bw

G5898.1/reads:
SRR1972955.done  SRR1972955.done_fastqc.html  SRR1972955.done_fastqc.zip  SRR1972955_1.fastq.gz  SRR1972955_2.fastq.gz

G5982.1:
alignment  reads

G5982.1/alignment:
G5982.1.bam  G5982.1.bam.bai  G5982.1.bw

G5982.1/reads:
SRR1972956.done  SRR1972956.done_fastqc.html  SRR1972956.done_fastqc.zip  SRR1972956_1.fastq.gz  SRR1972956_2.fastq.gz

G5985.1:
alignment  reads

G5985.1/alignment:

G5985.1/reads:

G5988.1:
alignment  reads

G5988.1/alignment:

G5988.1/reads:

G5997.1:
alignment  reads

G5997.1/alignment:
G5997.1.bam  G5997.1.bam.bai  G5997.1.bw

G5997.1/reads:
SRR1972962.done  SRR1972962.done_fastqc.html  SRR1972962.done_fastqc.zip  SRR1972962_1.fastq.gz  SRR1972962_2.fastq.gz

G6104.1:
alignment  reads

G6104.1/alignment:
G6104.1.bam  G6104.1.bam.bai  G6104.1.bw

G6104.1/reads:
SRR1972973.done  SRR1972973.done_fastqc.html  SRR1972973.done_fastqc.zip  SRR1972973_1.fastq.gz  SRR1972973_2.fastq.gz
```