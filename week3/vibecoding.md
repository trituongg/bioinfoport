# VIBECODING

Have the AI do it.

# WRITING A SCRIPT?

## REFACTOR IT, MAKE IT MORE GENERIC.

1. Use variables
2. Comment for every line
3. fine tune options
4. separate all variables

Just like this, it makes the link and the file name appear less so that other user can modify it easily.
```
# The URL of the gff3 file
URL="ftp://ftp.ensembl.org/pub/current_gff3/ursus_maritimus/Ursus_maritimus.UrsMar_1.0.112.gff3.gz"

# The name of the gff3 file
GFF="polar_bear.gff"

# Download the gff3 file and store it in the file
curl ${URL} > ${GFF}.gz

# Unzip the file
gunzip ${GFF}.gz

# Make a new GFF file with only the features of type gene
cat ${GFF} | awk '$3 == "gene"' > genes.gff

# Print the number of genes
cat genes.gff | wc -l
```

or just like this
```
# Set the trace to show the commands as executed
set -uex

# The URL of the gff3 file
URL="ftp://ftp.ensembl.org/pub/current_gff3/ursus_maritimus/Ursus_maritimus.UrsMar_1.0.112.gff3.gz"

# The name of the gff3 file
GFF="polar_bear.gff"

# The name of the genes file
GENES="genes.gff"

# ------ NO CHANGES NECESSARY BELOW THIS LINE ------

# Download the gff3 file if it doesn't exist
if [ ! -f ${GFF} ]; then
    wget ${URL} -O ${GFF}.gz
fi

# Unzip the file and keep the original
gunzip -k ${GFF}.gz

# Make a new GFF file with only the features of type gene
cat ${GFF} | awk '$3 == "gene"' >${GENES}

# Print the number of genes
cat ${GENES} | wc -l
```

Here is a template for usage 

```
# Set the error handling and trace
set -uex

# Define all variables at the top.

# The URL of the file
URL="https://example.com/somedata.txt"

# The name of the file
FILE="mydata.txt"

# - ALL DEFINTIONS ARE ABOVE - ALL ACTIONS ARE BELOW -

# List all the actions here.

# Download data into file
curl ${URL} > ${FILE}
```

Important: 
1. Don't install software
2. Set the trace
3. Command line parameters, just like this 
```
# The URL of the gff3 file
URL=$1

# The name of the gff3 file
GFF=$2

# The name of the genes file
GENES=$3

# ... the rest of the script ...
```
4. You can store command output as variables

## BASH IS A TERRIBLE LANGUAGE