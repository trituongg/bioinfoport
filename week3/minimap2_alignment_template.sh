# Align single end reads with minimap2.
minimap2 --MD -ax sr ${REF} ${R1} | \
         samtools sort > ${BAM}

# where the -x option specifies the preset to use. Here are some of the most useful presets:
# Preset:
#    -x STR       preset (always applied before other options;
# lr:hq - accurate long reads (error rate <1%) against a reference genome
# splice/splice:hq - spliced alignment for long reads/accurate long reads
# splice:sr - spliced alignment for short RNA-seq reads
# asm5/asm10/asm20 - asm-to-ref mapping, for ~0.1/1/5% sequence divergence
# sr - short reads against a reference
# map-pb/map-hifi/map-ont/map-iclr - CLR/HiFi/Nanopore/ICLR vs reference mapping
# ava-pb/ava-ont - PacBio CLR/Nanopore read overlap