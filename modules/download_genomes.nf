process DOWNLOAD_GENOMES {

    tag "$meta.id"
    label 'low'
    publishDir "results/genomes", mode: 'copy'
    conda "envs/ncbigenomedownload.yml"
    container 'containers/phiflow.sif'

    input:
    val meta
    path taxids
    val group

    output:
    path "genomes/*_genomic.fna.gz", emit: fasta, optional: false
    path "versions.yml", emit: versions

    script:
    def taxid_opt = taxids ? "--taxids ${taxids}" : ""

    """
    ncbi-genome-download \\
        --section refseq \\
        --assembly-level complete \\
        --formats fasta,gff \\
        --flat-output \\
        --output-folder genomes \\
        ${taxid_opt} \\
        ${group}

    echo "${task.process}:
        ncbigenomedownload: \$(ncbi-genome-download --version)" > versions.yml
    """
}