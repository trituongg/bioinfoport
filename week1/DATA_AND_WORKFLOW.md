# DATA AND WORKFLOW

## 1. BIOINFORMATICS DATA TYPE

![description](images/Screenshot%202026-04-18%20122028.png)
![description](images/workflow.png)

### As a summary 
Sequence information stored in file types of ```FASTA```, ````FASTQ```

Genomic intervals (coordinates) stored as files called ````BED```, ```GFF```, ```VCF```, ```BAM```

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