nextflow.enable.dsl=2

// incluir modulos
include { DOWNLOAD_GENOMES } from './modules/download_genomes.nf'
include { CONCATENATE_FASTA } from './modules/concatenate_fasta.nf'
include { INDEX_GENOME } from './modules/index_genomes.nf'
include { ALIGN_GENOME } from './modules/direct_align_reads.nf'
include { FILTER_READS } from './modules/filter_reads.nf'
include { GENERATE_COVERAGES } from './modules/generate_coverages.nf'
include { BREADTH_COVERAGE } from './modules/calculate_coverage.nf'


// Parâmetros
params.taxid_file = params.taxid_file ?: null
params.outdir     = params.outdir     ?: "./results"
params.group      = params.group      ?: "viral"
params.index_name = params.index_name ?: "viral_index"
params.index_dir  = "${params.outdir}/index/${params.index_name}"
//params.reads      = params.reads      ?: "/home/icastro/workspace/mock/plant_viral_mock.fastq"
params.reads_dir = params.reads_dir ?: "/home/icastro/workspace/simulated_reads"
params.breadth_threshold = params.breadth_threshold ?: 0.1





workflow {
    // Create channels
    Channel.value([ id: 'viral-genomes' ]).set { ch_meta }

    Channel.fromPath(params.taxid_file ?: '', checkIfExists: true)
        .ifEmpty { Channel.empty() }
        .set { ch_taxids }

    Channel.value(params.group)
        .set { ch_groups }


    ch_reads = createMixedReadsChannel(params.reads_dir)

    // Debug do canal
    //ch_reads.view { "DEBUG READS => $it" }
   
    
    //##############################
    // Download genomes
    genomes = DOWNLOAD_GENOMES(ch_meta,ch_taxids,ch_groups)
    // imprime o canal fasta
    //genomes.fasta.view() { "DEBUG GENOMES => $it" }
    merged = CONCATENATE_FASTA(genomes.fasta.collect())
    index = INDEX_GENOME(merged.fasta, params.index_name)
    //index.index_dir.view() { "DEBUG INDEX => $it" }
    
    // Align reads if input is provided
    if (params.reads_dir) {
        filtered_reads = FILTER_READS(ch_reads)
        //ALIGN_GENOME(filtered_reads,file(params.index_dir).toAbsolutePath().toString(),params.index_name)
        align = ALIGN_GENOME(filtered_reads,index.index_dir,params.index_name)
        covs = GENERATE_COVERAGES(align.bam,merged.fasta)
        BREADTH_COVERAGE(covs,merged.fai)
    }

}



def createMixedReadsChannel(reads_dir) {

    def items = []

    // Paired-end
    new File(reads_dir).eachFileMatch(~/.*_R1\.fastq(\.gz)?$/) { r1 ->
        def r2 = new File(reads_dir, r1.name.replace('_R1', '_R2'))
        if (r2.exists()) {
            def meta = [id: r1.name.replaceAll(/_R1\.fastq(\.gz)?$/, ""), single_end: false]
            items << [meta, [r1.path, r2.path]]
        }
    }

    // Single-end
    new File(reads_dir).eachFileMatch(~/.*\.fastq(\.gz)?$/) { f ->
        if (!f.name.matches(/.*_R[12]\.fastq(\.gz)?$/)) {
            def meta = [id: f.name.replaceAll(/\.fastq(\.gz)?$/, ""), single_end: true]
            items << [meta, f.path]
        }
    }

    return Channel.from(items)
}




    
    // Check if genome index already exists
   // if ( file(params.index_dir).exists() ) {
   //     log.info ">>> Índice já existe em ${params.index_dir}, pulando etapa INDEX_GENOME"
   // }else {
   //     log.info ">>> Criando indice ${params.index_dir}..."
    //}