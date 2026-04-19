# DATA AND WORKFLOW REPORT 2

## 1. BIOINFORMATICS DATA TYPE

![description](images/Screenshot%202026-04-18%20122028.png)
![description](images/workflow.png)

### As a summary 
Sequence information (ATCGATAC) stored in file types of ```FASTA```, ````FASTQ```

What about ```FASTA``` that is so special?

FASTA files always start with this ```>```

for example:

``` 
>alpha more info here
ACGTATTAATTAGGAGA
>beta other text here
GATACGGATGA

```

A real FASTA file might look like this (from Biostar)
```
>NC_045512.2 Severe acute respiratory syndrome coronavirus 2 isolate
ATTAAAGGTTTATACCTTCCCAGGTAACAAACCAACCAACTTTCGATCTCTTGTAGATCTGTTCTCTAAA
CGAACTTTAAAATCTGTGTGGCTGTCACTCGGCTGCATGCTTAGTGCACTCACGCAGTATAATTAATAAC
TAATTACTGTCGTTGACAGGACACGAGTAACTCGTCTATCTTCTGCAGGCTGCTTACGGTTTCGTCCGTG
TTGCAGCCGATCATCAGCACATCTAGGTTTCGTCCGGGTGTGACCGAAAGGTAAGATGGAGAGCCTTGTC
```

What is the sequence ID? -> ```NC_045512.2```

What is its description -> The thing that follows

What about soft vs hardmasking?

-> Masking (or hard masking) completely replaces data (e.g., repeating DNA sequences) with placeholders like 'N'. Making sure that tools ignore them
Example: 
```
>example
ATGCNNNNNNATGC
```

-> Soft masking marks data as lowercase instead of uppercase, preserving the underlying sequence information

Example: 

```
>example
ATGCtggcatcATGC
```

What about the FASTQ files? 

They store ```reads``` 

Sound familar? Those are the products of a sequencing run! 

Why does my professor always tell me to check if my sequencing run is a multiple of 4?

Because each entry in a ```FASTQ``` is 4 lines! So if it's off, there is some bad reads in your file. 

```
@some_id // Header
ACGTACGTACGTACGT // Sequence
+some_id // Header (again)
BBBBBBBBBBBBBBBB // Quality
```

Some actual read

```
@HWI-D00653:77:C6EBMANXX:7:1101:1429:1868
CGCCCGGTTAGCGATCAACAATGGACTGCATCATTTCATGCAGCTCGAGCCGATTGTAAGTCGCCCGTAACGCG
+HWI-D00653:77:C6EBMANXX:7:1101:1429:1868
#:=AA==EGG>FFCEFGDE1EFF@FEFFBBFGGGGGGDFGGG>@FGEGBGGGGGBGGGGGGGGFDFGGGGGBBG
```
Ugly right? Here are some Illumina specific ID

![description](images/Screenshot%202026-04-18%20155602.png)

What about the quality of a FASTQ?

-> It's encoded in ASCII characters and the more it looks like swearing, the more it is probably bad. The data is swearing at you. 

```
!"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHI  (FASTQ code)
|    |    |    |    |    |    |    |    | 
0    5   10   15   20   25   30   35   40  (error rate 10^(-N/10))
|    |    |    |    |    |    |    |    |
yuck..............meh................best  (interpretation)
```

Quick FASTQ check: 

```seqkit stats file.fastq ```

Genomic intervals (basically coordinates) stored as files called ````BED```, ```GFF```, ```VCF```, ```BAM```

```BAM``` = Binary map

```VCF``` = varaints

What about these ```BAM``` and ```SAM``` files?

```BAM``` = binary and ```SAM``` = sequence (```SAM``` is humanreadable but not really compact) Both of these are maps

How do I work with SAM or BAM files? Here is a biostar pipeline
```FASTA (reference) + FASTQ (reads) + aligner -> SAM (alignment) + Converter -> BAM (Yay!)```

How do I keep track of the ```SAM``` file complicated headers?
![descriptiom](images/Screenshot%202026-04-18%20161145.png)

What about Wiggle files or VCF? More on them later!

There are generic formats that we could call encylopedic formats such as ```GENBANK``` and ```EMBL```.
These are like storage systems.

Coordinate systems may different across data formats:

```GFF``` formats start counting at ```1```. The index of the second base is ```2```.

```BED``` formats start counting at ```0```. The index of the second base is ```1```.

Directionality: Most coordinate representations will display positions on the forward (positive) strand, even when describing features on the reverse (negative) strand.

For example, an interval ```[100, 200]``` may be used to describe a transcript on the reverse strand. The start column will contain ```100```.

In reality, the functional start coordinate is ```200``` as the feature is transcribed from the opposite direction.

Format naming
Different formats may have the same naming:

```MAF```: Multiple Alignment Format represents alignments of multiple sequences.
```MAF```: Mutation Annotation Format represents variants.

![description](images/tech.png)

What about these? According Biostar

**RNA-seq**: A technique for analyzing the **transcriptome** by sequencing **RNA** molecules, providing insights into gene expression levels and alternative splicing.

**ATAC-seq**: Assay for Transposase-Accessible Chromatin sequencing, used to study **chromatin accessibility** and identify open regions of DNA.

**WGS**: **Whole Genome Sequencing**, a method for determining the complete DNA sequence of an organism's genome.

**Iso-Seq**: A PacBio sequencing method for full-length transcript sequencing, enabling the identification of **alternative splicing** and gene isoforms.

**HiFi**: **High-Fidelity** sequencing, a PacBio technology that produces long, **highly accurate** reads for improved genome assembly and variant detection.

**Direct RNA**: A Nanopore sequencing technique that sequences **native RNA molecules without conversion to cDNA**, preserving RNA modifications.

**Long-read DNA**: Nanopore sequencing method for generating **long DNA reads**, useful for resolving complex genomic regions and structural variants.

How do I choose what to use?

Well, it depends on your research!

What kind of nucleic acid gets sequenced? 

![description](images/Screenshot%202026-04-18%20154431.png)
## 2. WHAT TO DO TO ANALYSE?

Be very careful and pay a lot of attention to details. A lot of the time, errors can arrive just because the data files have different ways of saying the same thing -> incompatiblity. 

## 3. THE ACTUAL REPORT 

*Prequisite: Downloading IGV from the terminal* I personally used conda instead of micromamba here

```
conda install -c bioconda igv
conda activate bioinfo
igv // this will give a lot of text like this 
Using system JDK. IGV requires Java 21.
openjdk version "21.0.10-internal" 2026-01-20
OpenJDK Runtime Environment (build 21.0.10-internal-adhoc.conda.src)
OpenJDK 64-Bit Server VM (build 21.0.10-internal-adhoc.conda.src, mixed mode, sharing)
WARNING: Unknown module: jide.common specified to --add-exports
WARNING: Unknown module: jide.common specified to --add-exports
WARNING: Unknown module: jide.common specified to --add-exports
WARNING: Unknown module: jide.common specified to --add-exports
WARNING: Unknown module: jide.common specified to --add-exports
WARNING: package com.sun.java.swing.plaf.windows not in java.desktop
WARNING: package sun.awt.windows not in java.desktop
WARNING: Unknown module: jide.common specified to --add-exports
WARNING: Unknown module: jide.common specified to --add-exports
Apr 18, 2026 9:47:19 AM java.util.prefs.FileSystemPreferences$1 run
INFO: Created user preferences directory. 
bla bla bla bla bla bla bla
```

**Use IGV to visualize your genome and the annotations relative to the genome.**
*I will use the fungi Trametes sanguinea as a genome reference*

Downloading the fasta = fna file
``` 
 wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/050/630/565/GCA_050630565.1_ASM5063056v1/*genomic.fna.gz
 ```

 why the *?. Since NCBI server is down and I can't find exactly the file name so this would have to do. If NCBI is too slow on terminal, you can try downloading from codespace

 Doing the same for the gff file

 ```
  wget -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/050/630/565/GCA_050630565.1_ASM5063056v1/*genomic.gff.gz
  ```

Remmeber to create a new folder and move your files (change the name if you'd like) into it and then ```gunzip * ``` them, 

Then you have to index them to create the ```.fai``` files which is needed by igv to navigate it

```
 ~/igv_test
$ samtools faidx Trametes.fna
(bioinfo)
tristuowngf@DESKTOP-OGB28J5 ~/igv_test
$ ls
Trametes.fna  Trametes.fna.fai  Trametes.gff
(bioinfo)
tristuowngf@DESKTOP-OGB28J5 ~/igv_test
$ head Trametes.fna.fai
lcl|JBLLKJ010000001.1_cds_KAL7284913.1_1        3000    243     80      81
lcl|JBLLKJ010000001.1_cds_KAL7284914.1_2        5268    3754    80      81
lcl|JBLLKJ010000001.1_cds_KAL7284915.1_3        3111    9358    80      81
lcl|JBLLKJ010000001.1_cds_KAL7284916.1_4        4320    12831   80      81
lcl|JBLLKJ010000001.1_cds_KAL7284917.1_5        1236    17411   80      81
lcl|JBLLKJ010000001.1_cds_KAL7284918.1_6        4707    19051   80      81
lcl|JBLLKJ010000001.1_cds_KAL7284919.1_7        2472    24152   80      81
lcl|JBLLKJ010000001.1_cds_KAL7284920.1_8        999     26925   80      81
lcl|JBLLKJ010000001.1_cds_KAL7284921.1_9        2289    28273   80      81
lcl|JBLLKJ010000001.1_cds_KAL7284922.1_10       5304    30953   80      81
(bioinfo)
tristuowngf@DESKTOP-OGB28J5 ~/igv_test
$
````

However, igv still doesn't recognize this. Why? So let's retry

Make sure the files you are using are these: 

```
-rw-rw-rw-  1 codespace codespace  11M May 30  2025 GCA_050630565.1_ASM5063056v1_genomic.fna.gz
-rw-rw-rw-  1 codespace codespace 2.2M Jul 11  2025 GCA_050630565.1_ASM5063056v1_genomic.gff.gz
```

The problem was I loaded the .fna file from ```file```, not ```genomes``` so it didn't worked. Mistakes happen. This is what after you load the .fna

![description](images/Screenshot%202026-04-18%20173449.png)

After you load the .gff after

![description](images/Screenshot%202026-04-18%20174034.png)

**How big is the genome, and how many features of each type does the GFF file contain?**

Using these 2 commands for the genome size 

```
tristuowngf@DESKTOP-OGB28J5 ~/igv_test
$ cat Trametes.fna | grep -v ">" | wc --char
40393765
(bioinfo)
tristuowngf@DESKTOP-OGB28J5 ~/igv_test
$ seqkit stats Trametes.fna
file          format  type  num_seqs     sum_len  min_len  avg_len    max_len
Trametes.fna  FASTA   DNA        104  39,895,024   26,363  383,606  4,110,638
(bioinfo)
tristuowngf@DESKTOP-OGB28J5 ~/igv_test
$
```
The resulst are either ```40393765``` or ```39,895,024```
**Why is there 2 biological answers?** --> Seqkit do not include Ns

For the gff
```
$ cat Trametes.gff | cut -f3 | sort-uniq-count-rank
71421   exon
69947   CDS
10505   gene
9031    mRNA
958     tRNA
516     rRNA
104     ##species https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=158606
104     region
1       #!genome-build ASM5063056v1
1       #!genome-build-accession NCBI_Assembly:GCA_050630565.1
1       #!gff-spec-version 1.21
1       #!processor NCBI annotwriter
1       ###
bla bla bla
```
However after installing agat, the results will be slightly different
```
 conda install -c bioconda agat
 agat_sp_statistics.pl --gff Trametes.gff
 bla bla bla bla 
 Compute region

Number of regions                            104
Number gene overlapping                      0
Total region length                          39895024
mean region length                           383606
Longest region                               4110638
Shortest region                              26363

--------------------------------------------------------------------------------

Compute mrna with isoforms if any

Number of genes                              9031
Number of mrnas                              9031
Number of cdss                               9031
Number of exons                              69947
Number of exon in cds                        69947
Number of intron in cds                      60916
Number of intron in exon                     60916
Number gene overlapping                      0
Number of single exon gene                   801
Number of single exon mrna                   801
mean mrnas per gene                          1.0
mean cdss per mrna                           1.0
mean exons per mrna                          7.7
mean exons per cds                           7.7
mean introns in cdss per mrna                6.7
mean introns in exons per mrna               6.7
Total gene length                            22994557
Total mrna length                            22994557
Total cds length                             16601394
Total exon length                            16601394
Total intron length per cds                  6393163
Total intron length per exon                 6393163
mean gene length                             2546
mean mrna length                             2546
mean cds length                              1838
mean exon length                             237
mean cds piece length                        237
mean intron in cds length                    104
mean intron in exon length                   104
Longest gene                                 16135
Longest mrna                                 16135
Longest cds                                  15219
Longest exon                                 8748
Longest cds piece                            8748
Longest intron into cds part                 9614
Longest intron into exon part                9614
Shortest gene                                120
Shortest mrna                                120
Shortest cds                                 102
Shortest exon                                2
Shortest cds piece                           2
Shortest intron into cds part                4
Shortest intron into exon part               4
ba bla bla 
 ```

**From your GFF file, separate the intervals of type "gene" or "transcript" into a different file. Show the commands you used to do this.**

I can use 
``` 
$ cat Trametes.gff | awk '$3 == "gene"' >> Trametes_genes.gff
(bioinfo)
```

**Visualize the simplified GFF in IGV as a separate track. Compare the visualization of the original GFF with the simplified GFF.**

```new problem, installing agat caused some error in my environment```

After only having the genes, it is less cluttered and does not really have overlapping segments

![description](images/Screenshot%202026-04-18%20203711.png)


**Zoom in to see the sequences, expand the view to show the translation table in IGV. Note how the translation table needs to be displayed in the correct orientation for it to make sense.**

![description](images/Screenshot%202026-04-18%20204243.png)
![description](images/Screenshot%202026-04-18%20204421.png)

**Visually verify that the first coding sequence of a gene starts with a start codon and that the last coding sequence of a gene ends with a stop codon.**

They do, one strand or another
