# Index the genome
bowtie2-build ${REF} ${REF}  # Build the Bowtie2 index

# Align the reads
bowtie2 -x ${REF} -1 ${R1} -2 ${R2} > ${SAM} 