process CONCATENATE_FASTA {
    tag "Concatenate FASTA files and create faidx file"
    label 'low'
    publishDir "results", mode: 'copy'
    conda "bioconda::bowtie2=2.5.4"
    container "quay.io/biocontainers/bowtie2:2.5.1--py39h5f740d0_2"

    input:
    path fasta_files

    output:
    path "genome_merged.fa", emit: fasta
    path "genome_merged.fa.fai", emit: fai


    script:
    """
    zcat ${fasta_files.join(" ")} > genome_merged.fa
    samtools faidx genome_merged.fa
    """
}