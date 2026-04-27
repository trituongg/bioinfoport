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