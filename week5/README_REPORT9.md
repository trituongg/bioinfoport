# VCF AND PREDICTION

## BEFORE WE START - TESTING PREVIOUS WEEK MAKEFILE

Since the orginal makefile_4.mk causes a lot of problems since it was designed to do entire full pipelines. We are going to create a new makefile that just do conversion to vcf

![alt text](image.png)

Let's redo the task from last week

```
Call variants for all samples
Run the variant calling workflow for all samples using your design.csv file.
Create a multisample VCF
Merge all individual sample VCF files into a single multisample VCF file (bcftools merge)
Visualize the multisample VCF in the context of the GFF annotation file.
```

Since we have 
```
$ ls -R G*/vcf
G5570.1/vcf:
G5570.1.vcf.gz  G5570.1.vcf.gz.tbi

G5644.1/vcf:
G5644.1.vcf.gz  G5644.1.vcf.gz.tbi

G5735.2/vcf:
G5735.2.vcf.gz  G5735.2.vcf.gz.tbi

G5985.1/vcf:
G5985.1.vcf.gz  G5985.1.vcf.gz.tbi

G5988.1/vcf:
G5988.1.vcf.gz  G5988.1.vcf.gz.tbi
```
We then use ```bcftools```

```
find G*/vcf -name "*.vcf.gz" > vcf.list
```

```bcftools merge \
    -l vcf.list \
    -Oz \
    -o merged.vcf.gz
```
Here is the final visualization image

![alt text](image-1.png)

## WEEK 10

Learning how to use ```VEP, SnpEff``` to well...predict stuff