# Step 14a: Download LEGO hap1 reference (NCBI datasets v18.28.0)

datasets download genome accession GCA_060154605.1 --include genome,gff3
unzip ncbi_dataset.zip
mv ncbi_dataset/data/GCA_060154605.1/*.fna lesser_goldfinch.fa

# Step 14b: Build split index for low-memory mapping (minimap2 v2.31)

minimap2 -x map-hifi -I 500M -d lesser_goldfinch.mmi lesser_goldfinch.fa

# Step 14c: Map trimmed HiFi reads to hap1 (minimap2 v2.31, samtools v1.24)

minimap2 -ax map-hifi -t 3 -K 50M --split-prefix lego_tmp \
  lesser_goldfinch.mmi \
  trimmedlego.fastq \
  | samtools view -b -o lego.unsorted.bam -

# Step 14d: Sort and index alignments (samtools v1.24)

samtools quickcheck lego.unsorted.bam && echo "OK"
samtools sort -@ 3 -m 768M -o lego.sorted.bam lego.unsorted.bam
samtools index -@ 3 lego.sorted.bam

# Step 14e: Mapping statistics (samtools v1.24)

samtools flagstat lego.sorted.bam

##################################################################
# Step 15: Per-scaffold read depth (samtools v1.24)

samtools coverage lego.sorted.bam > lego_coverage.tsv
