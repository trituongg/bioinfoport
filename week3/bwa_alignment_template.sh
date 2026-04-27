# Index the reference genome (only needs to be done once)
bwa index ${REF} 

# Align the paired-end reads
bwa mem ${REF} ${R1} ${R2} > ${SAM}

# Sort the SAM file to BAM
cat ${SAM} | samtools sort > ${BAM}

# Index the BAM file
samtools index ${BAM}