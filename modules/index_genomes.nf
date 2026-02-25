process INDEX_GENOME {
    tag "Build bowtie2 genome index"
    publishDir "${params.outdir}/index", mode: 'copy'

    conda "bioconda::bowtie2=2.5.4"
    container "quay.io/biocontainers/bowtie2:2.5.1--py39h5f740d0_2"

    input:
    path merged_fasta
    val index_name

    output:
    path "${index_name}", emit: index_dir

    script:
    """
    mkdir ${index_name}
    bowtie2-build $merged_fasta ${index_name}/${index_name}
    """
}