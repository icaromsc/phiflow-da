process ALIGN_GENOME {
    tag "$meta.id - Align reads to viral genomes"
    publishDir "${params.outdir}/align", mode: 'copy'

    conda "bioconda::bowtie2=2.5.4"
    container "quay.io/biocontainers/bowtie2:2.5.1--py39h5f740d0_2"
    
    input:
    tuple val(meta), path(reads)
    val index_dir
    val index_name
    
    output:
    tuple val(meta), path("${meta.id}.bam"), emit: bam
    
    script:
    if (!meta.single_end) {
        """
        set -euo pipefail
        bowtie2 -x ${index_dir}/${index_name} \
            -1 ${reads[0]} -2 ${reads[1]} \
            -S ${meta.id}.sam
        samtools view -bS ${meta.id}.sam > ${meta.id}.bam
        samtools sort -o ${meta.id}.sorted.bam ${meta.id}.bam
        mv ${meta.id}.sorted.bam ${meta.id}.bam
        """
    } else {
        """
        set -euo pipefail
        bowtie2 -x ${index_dir}/${index_name} \
            -U ${reads} \
            -S ${meta.id}.sam
        samtools view -bS ${meta.id}.sam > ${meta.id}.bam
        samtools sort -o ${meta.id}.sorted.bam ${meta.id}.bam
        mv ${meta.id}.sorted.bam ${meta.id}.bam
        """
    }
}
