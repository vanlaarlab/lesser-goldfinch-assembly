# Step 17: Evaluate helixer annotations (agat v1.2.0; busco v5.8.3)

#!/bin/bash
BASE=${BASE:?set BASE to the project directory}
cd "$BASE"
module load agat/1.2.0
mkdir -p eggnog/proteins

for sp in lego; do
  agat_sp_extract_sequences.pl \
    -g helixer/output/$sp/${sp}_pri.helixer.gff3 \
    -f genomes/$sp/${sp}_pri.fna \
    -p \
    -o eggnog/proteins/${sp}_pri.faa
done

ls -lh eggnog/proteins/
grep -c ">" eggnog/proteins/*.faa

grep -n "odb\|busco583" run_busco.sh
sbatch run_busco.sh
squeue -u $USER

agat_sp_statistics.pl \
  --gff helixer/output/lego/lego_pri.helixer.gff3 \
  -o helixer/output/lego/lego_pri.stats.txt