process FILTER_READS {
    tag "Filter low complexity reads"
    publishDir "results/filtered", mode: 'copy'

    conda "bioconda::fastp=0.23.4"
    container "quay.io/biocontainers/fastp:0.23.4--h5f740d0_3"
    
    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("${meta.id}_*_filtered.fastq"), emit: filtered
    
    script:
    if (!meta.single_end) {
        """
        fastp --in1 ${reads[0]} --in2 ${reads[1]} \
              --out1 ${meta.id}_R1_filtered.fastq --out2 ${meta.id}_R2_filtered.fastq \
              --low_complexity_filter --complexity_threshold 30 \
              -h ${meta.id}_fastp.html -j ${meta.id}_fastp.json
        """
    } else {
        """
        fastp --in1 ${reads} --out1 ${meta.id}_filtered.fastq \
              --low_complexity_filter --complexity_threshold 30 \
              -h ${meta.id}_fastp.html -j ${meta.id}_fastp.json
        """
    }
    // // Aqui, defino a variável `filtered` para capturar a saída correta
    // filtered =  meta.single_end ? [ file("${meta.id}_R1_filtered.fastq"), file("${meta.id}_R2_filtered.fastq") ]
    //                      : file("${meta.id}_filtered.fastq")
}