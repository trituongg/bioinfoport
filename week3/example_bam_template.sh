# Start with your aligned BAM file
INPUT="aligned.bam"
MAPPED="mapped.bam"

# Get initial statistics
echo "# --- Before filtering ---"
samtools flagstat $INPUT

# Keep only high-quality proper pairs
samtools view -F 4 -f 2 -q 20 $INPUT | \
    samtools sort -o $MAPPED

# Index the mapped BAM file
samtools index $MAPPED

# Final statistics
echo "# --- After filtering ---"
samtools flagstat $MAPPED