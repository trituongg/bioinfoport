#
# Turn a BAM file into a bigWig file
#

# Set the error handling and trace
set -uex

# The reference genome
REF=refs/ebola-1976.fa

# The BAM file
BAM=bam/SRR1972739.bam  

# The temporary bedgraph file
BG=bam/SRR1972739.bedgraph

# The BW wiggle file
BW=bam/SRR1972739.bw

# Index the reference genome
samtools faidx ${REF}

# Generate the temporary bedgraph file.
LC_ALL=C; bedtools genomecov -ibam  ${BAM} -split -bg | \
    sort -k1,1 -k2,2n > ${BG}

# Convert the bedgraph file to bigwig.
bedGraphToBigWig ${BG} ${REF}.fai ${BW}