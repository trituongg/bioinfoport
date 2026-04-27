# SCRIPTING WIZARD
## INTRO AND CONVETION
### ```\``` IS AN ESCAPE CHARACTER
when placed at the end of the line, it basically continues the next line. You might have seen this before

## WHAT ARE SHELL/BASH SCRIPT

### SHELL SCRIPTING
Program run by the Unix shell

### BASH SCRIPTING
Short text file intended to run in bash terminal

### WHAT TO USE?
VScode or Pycharm

### HOW TO COMMENT?
use the ```#``` symbol

```
#
# Download a dataset by an SRR run id.
#

# Limit download to 1000 reads during testing.
fastq-dump -X 10000 --split-files SRR519926

# FastQC report into a separate directory.
fastqc --outdir fastqc SRR519926_1.fastq SRR519926_2.fastq
```
IT IS ALWAYS A GOOD IDEA TO COMMENT ESPECIALLY THE NOT SO OBVIOUS 

HAVE SPACES, IT PREVENTS CODE ROT

### REFACTORING AND VARIABLE MAKING 
Basically optimzing your code. Also, when assigning variables, leave no space
Like this 
```
# The selected SRR number.
SRR=SRR519926
```
You can also call variables like this ```${FOO}```
the brackets make it compatible with ```Makefile```

Always start with ```set -uex```. There are caveats

```
-u (nounset): Treats using an undefined variable as an error → the script stops immediately.
-e (errexit): Exits the script as soon as any command returns a non-zero (error) status.
-x (xtrace): Prints each command before executing it (useful for debugging).
```

For example, some programs might seem to *"fail"* even though they didn't and make your script fail

1. Perpetrator - grep. Just like this 
```
# Bash strict mode.
set -uex

# Grep will raise an error code if there is no match.
echo FOO | grep BAR

# This will never be reached.
echo "all done!"
```

You can also add a ```||true``` to make it execute

Like so 
```
# Bash strict mode.
set -uex

# Grep will raise an error code if there is no match.
echo FOO | grep BAR || true

# Prints the end.
echo "all done!"
```

You can add run time parameters
```
# Get the name as the first argument.
NAME=$1

# Print the welcome.
echo Hello ${NAME}!
```
The ```$1``` will get the first input

Just like this 
```
# Downloads an SRR run.
# Converts a LIMIT number of spots.
# Assumes the data is in paired-end format.
# Runs FastQC on each resulting FastQ file.

# Stop on any error.
set -ue

# The first parameter is the SRR number.
SRR=$1

# The second parameter is the conversion limit.
LIMIT=$2

# Remind user what is going on.
echo "Rock on! Getting ${LIMIT} spots for ${SRR}"

# Get the data from SRA.
fastq-dump -X ${LIMIT} --split-files ${SRR}

# Run FastQC on the resulting datasets.
fastqc ${SRR}_1.fastq ${SRR}_2.fastq
```

```-x``` will trace commands
```
+ NAME=John
+ ls -l
+ wc -l
+ echo 'All done John'
+ wc -c
      14
```

IMPORTANT ABOUT USING QUOTATION MARKS
```
# Set the name.
NAME=John

# Demonstrate the effects of various quotes.
echo Hello $NAME
echo "Hello $NAME"
echo 'Hello $NAME'
```
Will result 
```
Hello John
Hello John
Hello $NAME
```
So use double quotation marks for variable change and single quotation mark for verbatim output

Variables can store output too like this 
```
DATE=$(date "+%A %B %d, %Y")

echo ${DATE}
``` 
which will put out ```Tuesday January 17, 2023```

``` `value` ```. Using backticks can produce the same output

The shell already have some defined variables like ```PATH``` so don't change them. 

TABs and spaces are different, be sure to check them 

```
cat -te data.txt

A       B    $
C^ID$
``` 
```^I``` are tabs. 

## HOW TO AUTOMATE SCRIPTING
1. DO NOT USE SUBOPTIMAL LOOPS
```
for FNAME in *.fastq
    fastqc $NAME
done
``` 
Like this

### USE PARALLEL LOOPS
```
cat files.txt | parallel fastqc {}
```
where files.txt contains the file names/ids you are using. 

For variant calling 
```
cat ids.txt | parallel variantcaller -i {}.bam -o {}.vcf.gz
```

You can create the id file from your command line like this
```
$ parallel echo {} > ids.txt ::: SRR3191542 SRR3191545 SRR3194429

$ head ids.txt
SRR3191542
SRR3191545
SRR3194429
```

Basically, use ```parallel``` as much as you can

### EXPLICIT LOOP = BAD PARALLEL = GOOD
```
cat ids.txt | parallel trim -i {}.fastq -o {}.trimmed.fastq
cat ids.txt | parallel align {}.trimmed.fastq -o {}.bam
cat ids.txt | parallel call -i {}.bam -o {}.vcf.gz
``` 
Instead of
```
for fname in *.fastq
    fastqc $fname
    trim -i $fname -o $fname.trimmed.fastq
    align -i $fname.trimmed.fastq -o $fname.bam
    call -i $fname.bam -o $fname.vcf.gz
done
```
 YUCK!

### THE AMPERSAND (&) ALLOWS CODE TO RUN IN THE BACKGROUND

## THE RIGHT WAY TO DO IT
### FIND THE ROOTS

```
M5uM_2_S5_R1_001.fastq.gz
M5uM_2_S5_R2_001.fastq.gz
Z8uM_2_S8_R1_001.fastq.gz
Z8uM_2_S8_R2_001.fastq.gz
CTRL_2_S2_R1_001.fastq.gz
CTRL_2_S2_R2_001.fastq.gz
```
What are the roots?
```
M5uM_2_S5
Z8uM_2_S8
CTRL_2_S2
```

### WHAT IS PARALELL AGAIN?

GNU tool
```
parallel somecommand {} ::: A B C 
=
somecommand A
somecommand B
somecommand C
```

In a file called ```parallel_test.sh``` we can test parallel there

```
# create id.txt file for our values
parallel echo {} ::: SRR1553607 SRR1972917 > ids.txt

# we get the ids and then download them 
cat ids.txt | parallel fastq-dump --split-files -X 10000 {}

# we get the ids and then trim them
cat ids.txt | parallel fastp -i {}_1.fastq -o {}_1.trimmed.fq --max_len1 20
```
What does the third command actually execute?
```
fastp -i SRR1553607_1.fastq -o SRR1553607_1.trimmed.fq --max_len1 20
fastp -i SRR1972917_1.fastq -o SRR1972917_1.trimmed.fq --max_len1 20
```
So instead of really long loops we can have parallel commands that run this automatically!

Using paralell allow us to build full names from the ids (i.e. in a constructive manner)

For paired ends reads

```
# Obtain data from SRA.
cat ids.txt | parallel fastq-dump --split-files -X 10000 {}

# Cut the paired-end reads back to 20 bp.
cat ids.txt | parallel fastp -i {}_1.fastq -o {}_1.trimmed.fq \
                             -I {}_2.fastq -O {}_2.trimmed.fq \
                             --max_len1 20 --max_len2 20
```
There are 2 things of note here. 
1) Remember the backslash ```\``` (it is used to continue 1 command line argument)
2) Parallel usage becomes more apparent

## YET ANOTHER SHORT GUIDE TO PARALLEL

In practice, you should always use quotation mark around the parallel command
```echo Joe | parallel "echo Hey {} > {}.txt"``` will create a file called Joe.txt with the words "Hey Joe"
vs
```echo Joe | parallel echo Hey {} > {}.txt``` will  create a file called {}.txt that contains "Hey Joe"

You can have delim as well
```echo FOO,BAR | parallel -d ,  echo Hello {}``` will echo out Hello FOO and Hello Bar. No comma = Hello FOO,BAR

```colsep``` can be used as well (column separator)

```echo FOO,BAR | parallel --colsep ','  echo Hello {2} and {1}```

gives
```Hello BAR and FOO```

You can also do 

```
cat design.csv | parallel --header : --colsep ,
                 echo command -i {sra}.fastq -o {sample}.bam
```
Which means basically
1) Cat out the content of ```design.csv```
2) The first row is a header row
3) Each column is separated by a comma 
4) for each row echo out the result of the command that input the value in the sra+.fastq column and the out the sample+.bam

You can do combinations as well 

```parallel echo Hello {} and {} ::: A B ::: 1 2``` 
gives 
```
Hello A 1 and A 1
Hello A 2 and A 2
Hello B 1 and B 1
Hello B 2 and B 2
```
using numbers in the brackets can also work 
```parallel echo Hello {1} and {2} ::: A B  ::: 1 2```

```
Hello A and 1
Hello A and 2
Hello B and 1
Hello B and 2
```

### EXERCISES 
First have this file ```parallel echo {} ::: A B C > ids.txt```

What will these do 
```
# Example 1 
cat ids.txt | parallel echo {} {} {} 
```
Since the file will read each value and then put them in the brackets it will print something along the lines of
```
A A A
B B B
C C C
```

```
# Example 2
cat ids.txt | parallel echo {} {} {} > {}.txt
``` 
It will result in something like creating a {}.txt with each having the corresponding letter repeated 3 times

```
head \{\}.txt
A A A
B B B
C C C
```

```
# Example 3
cat ids.txt | parallel "echo {} {} {} > {}.txt"
```
Since we now have a quotation mark, it will create the A,B,C files with each having the corresponidng letter repeated 3 times

```
 head *.txt
==> A.txt <==
A A A

==> B.txt <==
B B B

==> C.txt <==
C C C
```

```
# Example 4
cat ids.txt | parallel "echo {} {} {} \> {}.txt"
```
The backslash here is basically an escape character, no ```>``` is happening 
So the shell will echo out each of the letters 3 times and the >+letter.txt 
```
A A A > A.txt
B B B > B.txt
C C C > C.txt
```


```
# Example 5
cat ids.txt | parallel "echo echo {} {} {} \> {}.bar.txt" | bash
```
The second echo basically make the first echo a command that will be executed by bash and will create the files A.bar.txt B.bar.txt etc each with their correponding letters repeated 3 times

```
 head *.txt
==> A.bar.txt <==
A A A

==> B.bar.txt <==
B B B

==> C.bar.txt <==
C C C
```

```
# Example 6
parallel "echo {1}={2}" :::: ids.txt ::: 1 2
```
It will take each letter in ids.txt as input for the {1} and the numbers for the {2}
```
parallel "echo {1}={2}" :::: ids.txt ::: 1 2
A=1
A=2
B=1
B=2
C=1
C=2
```

## MASTERING PARALLEL
### MISC

You want to blast a 1gb file?
```
cat 1gb.fasta | parallel --block 100k --recstart '>' --pipe \
                blastp -evalue 0.01 -outfmt 6 -db db.fa -query - > results
```

blasting with multiple cores?
```
cat 1gb.fasta | parallel -S :,server1,server2 --block 100k --recstart '>'
                --pipe blastp -evalue 0.01 -outfmt 6 -db db.fa -query - > result
```


blat?
```cat foo.fa | parallel --round-robin --pipe --recstart '>' \
             'blat -noHead genome.fa stdin >(cat) >&2' >foo.psl
```

bigwigtowig?

```
parallel bigWigToWig -chrom=chr{} wgEncodeCrgMapabilityAlign36mer_mm9.bigWig \
         mm9_36mer_chr{}.map ::: {1..19} X Y M
```

You can also run composed commands btw

```
parallel 'read_fasta -i {} | extract_seq -l 5 | write_fasta -o {.}_trim.fna -x' ::: *.fna
```

experiment?
```
parallel --results outputdir experiment --age {1} --sex {2} --chr {3} \
         ::: {1..80} ::: M F ::: {1..22} X Y
```

You can also name them 
```
parallel --result outputdir --header : experiment --age {AGE} --sex {SEX} \
         --chr {CHR} ::: AGE {1..80} ::: SEX M F ::: CHR {1..22} X Y
```

```--shuf``` can be used to randomize order

# MAKE AND MAKEFILES - WHERE REPRODUCBILITY BEGINS
## PROLOGUE
What is a makefile? Script with targets

Say you have this script
```
foo:
--> echo Hello John!

bar:
--> echo Hello Jane!
--> echo Hello Everyone!
```
```make foo``` gives
```Hello John!```
and ```make bar``` gives
```
Hello Jane!
Hello Everyone!
```
The default is the tab and you can change it using ```.RECIPEPREFIX```
```
.RECIPEPREFIX = >

foo:
> echo Hello John!

bar:
> echo Hello Jane!
> echo Hello Everyone!
```

in a make file called ```Makefile```
```
.RECIPEPREFIX = >

NAME = Jane

usage:
> @echo "Usage: make hello, goodbye, ciao"

hello:
> @echo Hello ${NAME}
```

What does the ampersand do "@" 

-> @ suppresses the command itself from being printed.

## MAKEFILE TIPS

Try dry running ```-n```

You can also take arguments from command lines
```
# Set the value of FOO to bar (if not already set).
NAME ?= Jane

# Sets the prefix for commands.
.RECIPEPREFIX = >

usage:
> echo Hello ${NAME}
```
Jane can then be overidden ```make usage NAME=Joe```

Use these for makefiles for safety
```
# Deletes dependencies if the command fails.
.DELETE_ON_ERROR:

# Warns about undefined variables.
MAKEFLAGS += --warn-undefined-variables --no-builtin-rules
```

## BIOINFORMATICS AND MAKEFILES
Keep it simple
Do not always aim for complete automation, a step by step is alright
We can create a Makefile that allows use to do each step of the process
```
make data PRJN=PRJEB31790
```
```
make trim PRJN=PRJEB31790
```
Remember a makefile is something with a target

in a ```Makefile``` have this
```
# Set the prefix from tabs to >
.RECIPEPREFIX = >

# Sets the default target.
PRJN ?= PRJEB31790

# How many runs to download
N ?= 5

usage:
> @echo ""
> @echo "Usage: make data trim N=${N} PRJN=${PRJN}"
> @echo ""

data:
# Search database for SRA data and make a csv file with run information.
> esearch -db sra -query ${PRJN} | efetch -format runinfo > runinfo.csv

# Extract sequencing run ids from runinfo. Start with second line (skip header).
> cat runinfo.csv | csvcut -c Run | grep -v Run | head -5 > ids.txt

# Make a directory for the reads.
> mkdir -p reads

# Download data from SRA.
> cat ids.txt | parallel --progress fastq-dump -O reads -X 10000 --split-files {}

# Run fastqc on each read.
> cat ids.txt | parallel --progress fastqc reads/{}_1.fastq reads/{}_2.fastq

trim:

# Make directory for trimmed reads.
> mkdir -p qc

# Apply quality control to each read.
> cat ids.txt | parallel --progress fastp \
                -i reads/{}_1.fastq -I reads/{}_2.fastq \
                -o qc/{}_1.trim.fq  -O qc/{}_2.trim.fq  \
                --adapter_sequence AGATCGGAAGAGCACACGT

# Run fastqc on each trimmed dataset.
> cat ids.txt | parallel --progress fastqc qc/{}_1.trim.fq qc/{}_2.trim.fq

# Non file targets.
.PHONY: clean usage data trim

```
so you can have the make file do 
1. data
2. trim

and you can change the SRA number from the command line. How awesome!

an improved makefile that has everything
```
# Sets the prefix for commands.
.RECIPEPREFIX = >

# Sets the default target.
PRJN ?= PRJEB31790

# How many runs to download
N ?= 5

# Default action is to print usage.
usage:
> @echo ""
> @echo "Usage: make data trim N=${N} PRJN=${PRJN}"
> @echo ""

runinfo.csv:
# Search database for SRA data and make a csv file with run information.
> esearch -db sra -query ${PRJN} | efetch -format runinfo > runinfo.csv

ids.txt: runinfo.csv
# Extract sequencing run ids from runinfo. Start with second line (skip header).
> cat runinfo.csv | csvcut -c Run | grep -v Run | head -5 > ids.txt

data: ids.txt
# Make a directory for the reads.
> mkdir -p reads

# Download data from SRA.
> cat ids.txt | parallel --progress fastq-dump -O reads -X 10000 --split-files {}

# Run fastqc on each read.
> cat ids.txt | parallel --progress fastqc reads/{}_1.fastq reads/{}_2.fastq

trim:
# Make directory for trimmed reads.
> mkdir -p qc

# Apply quality control to each read.
> cat ids.txt | parallel --progress fastp \
                -i reads/{}_1.fastq -I reads/{}_2.fastq \
                -o qc/{}_1.trim.fq  -O qc/{}_2.trim.fq  \
                --adapter_sequence AGATCGGAAGAGCACACGT

# Run fastqc on each trimmed dataset.
> cat ids.txt | parallel --progress fastqc qc/{}_1.trim.fq qc/{}_2.trim.fq

# Run all commands in one shot.
all: data trim

clean:
> rm -rf qc reads runinfo.csv ids.txt fastp*

# Non file targets.
.PHONY: clean usage data trim
```

```ids.txt: runinfo.csv``` or ```data: ids.txt``` will only happen if runinfo.csv or ids.txt exist!

## HOW TO MAKE MAKEFILE DEPENDENCIES?

take this script
```
# Input accession numbers
ACC ?= AF086833
SRR ?= SRR1972917

# How many reads to unpack.
N ?= 1000

# The reference file
REF = refs/${ACC}.fa

# The index file for the reference
IDX = ${REF}.amb

# The aligned BAM file.
BAM = bam/${SRR}-${ACC}.bam

# The variant file.
VCF = vcf/${SRR}-${ACC}.vcf.gz

# The read pairs.
R1 = reads/${SRR}_1.fastq
R2 = reads/${SRR}_2.fastq

# Set the prefix from tabs to >
.RECIPEPREFIX = >

usage:
> @echo "Usage: make vcf ACC=AF086833 SRR=SRR1972917 N=1000"

# This is how we obtain the reference..
${REF}:
> mkdir -p refs
> bio fetch ${ACC} -format fasta > ${REF}

# This is how we obtain the reads.
${R1} ${R2}:
> mkdir -p reads
> fastq-dump -F --split-files -O reads -X ${N} ${SRR}

# The index depends on the reference.
${IDX}: ${REF}
> bwa index ${REF}

# The alignment depends on index and the reads.
${BAM}: ${IDX} ${R1} ${R2}
> mkdir -p bam
> bwa mem ${REF} ${R1} ${R2} | samtools sort > ${BAM}
> samtools index ${BAM}

# The VCF file depends on the BAM file.
${VCF}: ${BAM}
> mkdir -p vcf
> bcftools mpileup -O v -f ${REF} ${BAM}  | \
           bcftools call --ploidy 1 -m -v -O z -o ${VCF}
> bcftools index ${VCF}

# Trigger the VCF generation
vcf: ${VCF}
```

```
# The index depends on the reference.
${IDX}: ${REF}
```

```
# The VCF file depends on the BAM file.
${VCF}: ${BAM}
```

## Troubleshotting

```make: *** No rule to make target 'bennifer:'. Stop.``` means  ```bennifer``` is not a target in your script
```Makefile:3: *** missing separator.  Stop.``` means that your task weren't  delimited

tab delimited will look like this
```
cat -t Makefile

foo:
^Iecho Hello John!

bar:
^Iecho Hello Jane!
^Iecho Hello Everyone!
```

adding a ```-``` can make you run the file even if it failed

## MY/YOUR MAKE FILES ARE WRONGG!!!!

1. Don’t use tabs use ```.RECIPEPREFIX = >``` 
2. Use a recent bash ```SHELL := bash```
3. Use strict mode (not universal) ```.SHELLFLAGS := -eu -o pipefail -c```
4. bla bla bla

```
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
```

What about ```.PHONY```
```
test:
> npm run test
.PHONY: test  # Make will not look for a file named `test` on the file system
```
You use this when you want make to run. Make usually won't run when there is already a file with the same name in the system because it thinks the file is already up to date.

about ```$$```

```
echo $HOME   #  Make tries to expand it
echo $$HOME  #  shell expands it
```

Q: Andy defined HOME = my_house.txt in his Makefile, but when he used $$HOME it caused an error. Why?

A: Because $$HOME does not refer to the Make variable HOME.

### MISC 
THIS IS NOT DOGMA