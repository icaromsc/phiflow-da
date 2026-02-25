process BREADTH_COVERAGE {
    
    tag "Calculate breadth of coverage"
    publishDir "results/summary", mode: 'copy'
    conda "envs/breadth_coverage.yml"
    
    input:
    path mpileup_cov
    path fasta_fai
    
    output:
    path "breadth_coverage.tsv" , emit: breadth_tsv
    path "breadth_coverage_plot.png" , emit: breadth_plot
    path "genome_coverage_plot.pdf" , emit: genome_cov_plot

    script:
    """
    calc_breadth_coverage.py \
        --input ${mpileup_cov} \
        --fai ${fasta_fai} \
        --threshold 0.1 \
        --output breadth_coverage.tsv \
        --plot breadth_coverage_plot.png
    plot_coverage.py ${mpileup_cov} ${fasta_fai} genome_coverage_plot.pdf
    """
}
