nextflow run main.nf \
  --group viral \
  --taxid_file human-viral-genomes.txt \
  --outdir results \
  -profile conda \
  -resume \
