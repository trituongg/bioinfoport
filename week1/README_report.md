# REPORT 1

*Do not randomly use the sudo get command from Linux, it may cause clash of versions.*

*Conda, mamba, micromamba are package managers. Biostar handbook use micromamba.*

To start:

```curl http://data.biostarhandbook.com/install.sh | bash ```

*Fastqc dump keep having errors because NCBI can't make themselves better servers.*

*At least downloading via a codespace actually helped because it sort of have a different server?*

## 1. Basic information about GFF Files.

![Description](images/image_1.png)

GFF stands for Generic Feature Format. GFF files are **nine-column**, **tab-delimited**, plain text files used to represent coordinates in one dimension (along an axis). See the GFF3 specification for more details.

The columns are:

- `SEQID` – the name of the sequence  
- `SOURCE` – the source (origin) of the feature  
- `FEATURE` – the type of feature  
- `START` – the start position of the feature  
- `END` – the end position of the feature  
- `SCORE` – the score of the feature  
- `STRAND` – the strand of the feature  
- `PHASE` – the phase of the feature (0, 1, or 2)  
- `ATTRIBUTES` – the attributes of the feature  

A general GFF file may look like this:

```bash
bio fetch NC_045512 -format gff | head -5

NC_045512.2  RefSeq  region          1      29903  .  +  .  ID=NC_045512.2:1..29903;Dbxref=taxon:2697049;collection-date=Dec-2019;country=China;gb-acronym=SARS-CoV-2;gbkey=Src;genome=genomic;isolate=Wuhan-Hu-1;mol_type=genomic RNA;nat-host=Homo sapiens
NC_045512.2  RefSeq  five_prime_UTR  1      265    .  +  .  ID=id-NC_045512.2:1..265;gbkey=5'UTR
NC_045512.2  RefSeq  gene            266    21555  .  +  .  ID=gene-GU280_gp01;Name=ORF1ab
NC_045512.2  RefSeq  CDS             266    13468  .  +  0  ID=cds-YP_009724389.1;Parent=gene-GU280_gp01
```
# 2. Analysis of GFF file of choice

## Prerequisite: Activate environment and check health

```bash
micromamba activate bioinfo
```

You can run `doctor.py` to be sure.

---

## 1. Organism overview

We are analyzing **Cottoperca gobio**, commonly known as the *channel bull blenny*.

This is a species of fish used in genomic annotation datasets.

---

## 2. Number of sequence regions (chromosomes)

Download and decompress the file:

```bash
wget https://ftp.ensembl.org/pub/current_gff3/cottoperca_gobio/Cottoperca_gobio.fCotGob3.1.115.chr.gff3.gz
gunzip Cottoperca_gobio.fCotGob3.1.115.chr.gff3.gz
```

Count sequence regions:

```bash
grep -v "^#" Cottoperca_gobio.fCotGob3.1.115.chr.gff3 | cut -f1 | sort | uniq -c
```

Result:

```
  80461 1
  34483 2
  72422 3
  77848 4
  89569 5
  83012 6
  75631 7
  74081 8
  91314 9
  55654 10
  55424 11
  69015 12
  67790 13
  74540 14
  69720 15
  64752 16
  81218 17
  38696 18
  65567 19
  45049 20
  65379 21
  65085 22
  43423 23
  57349 24
```

### Conclusion:
There are approximately **24 chromosomes**, which matches expectations for this organism.

---

## 3. Number of feature types in the file

Command:

```bash
grep -v "^#" Cottoperca_gobio.fCotGob3.1.115.chr.gff3 | cut -f3 | sort | uniq -c
```

Result:

```
724770 CDS
14 J_gene_segment
26 V_gene_segment
1 Y_RNA
11897 biological_region
743204 exon
21630 five_prime_UTR
20270 gene
2075 lnc_RNA
54260 mRNA
90 miRNA
2593 ncRNA_gene
236 pseudogene
236 pseudogenic_transcript
545 rRNA
24 region
7 scRNA
136 snRNA
240 snoRNA
15197 three_prime_UTR
31 transcript
```

---

## 4. Number of genes

From the output:

- **Gene count: ~20,270 genes**

---

## 5. Less familiar feature types

| Feature | System | Function |
|----------|--------|----------|
| V_gene_segment | Immune system | Antigen-binding diversity |
| J_gene_segment | Immune system | Gene segment joining |
| Y_RNA | RNA regulation | Non-coding RNA involved in DNA replication and regulation |

---

## 6. Top ten annotated feature types

Sorted counts:

```
743204 exon
724770 CDS
54260 mRNA
21630 five_prime_UTR
20270 gene
15197 three_prime_UTR
11897 biological_region
2593 ncRNA_gene
2075 lnc_RNA
545 rRNA
240 snoRNA
236 pseudogene
236 pseudogenic_transcript
136 snRNA
90 miRNA
31 transcript
26 V_gene_segment
24 region
14 J_gene_segment
7 scRNA
1 Y_RNA
```

### Key insight:
The most abundant feature is **exon (743,204 entries)**.

---

## 7. Is the annotation complete and high quality?

Yes.

- Chromosome-level assembly is present
- High number of annotated genes and transcripts
- Balanced annotation of coding (CDS, exons) and regulatory features
- Presence of UTRs, ncRNAs, and immune-related gene segments indicates curated annotation

Overall, this suggests a **well-annotated, high-quality reference genome**.

---

## 8. Additional insights

Ensembl GFF files come in different annotation levels:

| File type | Scope | Content quality | Typical use |
|------------|------|----------------|--------------|
| `.chr.gff3` | Chromosomes only | Curated, clean | Standard genomic analysis |
| `.gff3` | Full assembly | Includes scaffolds | Complete genome analysis |
| `.abinitio.gff3` | Gene predictions only | Lower confidence | Gene prediction / exploratory analysis |

---

