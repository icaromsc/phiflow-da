process GENERATE_COVERAGES {
    tag "Generate genome coverages using mpileup"
    publishDir "${params.outdir}/mpileup", mode: 'copy'
    conda "bioconda::bowtie2=2.5.4"
    container "quay.io/biocontainers/bowtie2:2.5.1--py39h5f740d0_2"

    input:
    tuple val(meta), path(bam_files)
    path fasta_ref
    
    output:
    path "${meta.id}_coverage.mpileup"

    script:
    """
    samtools mpileup -aa -f ${fasta_ref} ${bam_files} > "${meta.id}_coverage.mpileup"
    """
}