# Calculate coverage depth
samtools depth input.bam | head

# Find regions with highest coverage
samtools depth input.bam | sort -k3 -nr | head

# Calculate coverage for all positions (including zero coverage)
samtools depth -a input.bam | head