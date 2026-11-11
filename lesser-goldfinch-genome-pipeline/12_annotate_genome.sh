# Step 16: Annotate primary LeGo assembly (Helixer v0.3.7)

set -uo pipefail
die() { echo "ERROR: $*" >&2; exit 1; }

module load miniconda3/3.13
conda activate apptainer
 
BASE=${BASE:?set BASE to the project directory}
SIF=${SIF:-$BASE/helixer/helixer-docker_latest.sif}
GENOMES=($BASE/genomes/lego/lego_pri.fna)
GENOME=${GENOMES[$SLURM_ARRAY_TASK_ID]:-}
 
echo "=== $(date)  node=$(hostname)  task=$SLURM_ARRAY_TASK_ID"
[ -n "$GENOME" ] && [ -s "$GENOME" ] || die "genome not found: '$GENOME'"
[ -e "$SIF" ] || die "container not found: $SIF"
 
NAME=$(basename "$GENOME" .fna)
SP=$(basename "$(dirname "$GENOME")")
OUT=$BASE/helixer/output/$SP
mkdir -p "$OUT" || die "cannot create $OUT"
echo "genome=$GENOME  output=$OUT/$NAME.helixer.gff3"
 
[ -s "$OUT/$NAME.helixer.gff3" ] && { echo "Output exists, skipping."; exit 0; }
 
singularity run --nv --bind "$BASE":"$BASE" --pwd "$BASE" "$SIF" Helixer.py \
  --fasta-path "$GENOME" \
  --lineage vertebrate \
  --gff-output-path "$OUT/$NAME.helixer.gff3.tmp" \
  || die "Helixer exited with an error"
 
N=$(grep -c -P "\tgene\t" "$OUT/$NAME.helixer.gff3.tmp" || true)
[ "${N:-0}" -gt 0 ] || die "output has no gene features"
mv "$OUT/$NAME.helixer.gff3.tmp" "$OUT/$NAME.helixer.gff3"
echo "=== done: $N genes  $(date)"