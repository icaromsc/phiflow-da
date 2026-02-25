nextflow run main.nf \
    --taxid_file assets/human-viral-genomes.txt \
    --reads_dir /home/icastro/workspace/phiflow-da/tests/data \
    --outdir final_results \
    -profile conda