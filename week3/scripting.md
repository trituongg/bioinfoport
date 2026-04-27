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