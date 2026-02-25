nextflow.enable.dsl=2

// 1. Include modules
include { DOWNLOAD_GENOMES    } from './modules/download_genomes.nf'
include { CONCATENATE_FASTA    } from './modules/concatenate_fasta.nf'
include { INDEX_GENOME         } from './modules/index_genomes.nf'
include { FILTER_READS         } from './modules/filter_reads.nf'
include { ALIGN_GENOME         } from './modules/direct_align_reads.nf'
include { GENERATE_COVERAGES   } from './modules/generate_coverages.nf'
include { BREADTH_COVERAGE     } from './modules/calculate_coverage.nf'

<<<<<<< HEAD
// 2. Parameters (Defaults are handled in nextflow.config, these are fallback)
params.taxid_file       = params.taxid_file ?: null
params.outdir           = params.outdir     ?: "./results"
params.group            = params.group      ?: "viral"
params.index_name       = params.index_name ?: "viral_index"
params.reads_dir        = params.reads_dir  ?: null
=======

// Parâmetros
params.taxid_file = params.taxid_file ?: null
params.outdir     = params.outdir     ?: "./results"
params.group      = params.group      ?: "viral"
params.index_name = params.index_name ?: "viral_index"
params.index_dir  = "${params.outdir}/index/${params.index_name}"
//params.reads      = params.reads      ?: "/home/icastro/workspace/mock/plant_viral_mock.fastq"
params.reads_dir = params.reads_dir ?: null
>>>>>>> d7b76a8df65a8d7cb5d83e873ecd4eb2d67a6b24
params.breadth_threshold = params.breadth_threshold ?: 0.1

// Helper path for logic
def index_dir = "${params.outdir}/index/${params.index_name}"

workflow {
    // --- Initial Parameter Validation ---
    if (!params.reads_dir) { 
        error "ERROR: No reads directory provided. Please use --reads_dir <path>" 
    }

    // --- Channel Initialization ---
    Channel.value([ id: 'viral-genomes' ]).set { ch_meta }
    Channel.value(params.group).set { ch_groups }

    // Handle optional TaxID file
    if (params.taxid_file) {
        ch_taxids = Channel.fromPath(params.taxid_file, checkIfExists: true)
    } else {
        ch_taxids = Channel.empty()
    }

    // Use the robust, native channel creator for FASTQs
    ch_reads = createMixedReadsChannel(params.reads_dir)

    // --- Core Workflow Steps ---

    // 1. Reference Retrieval and Preparation
    genomes = DOWNLOAD_GENOMES(ch_meta, ch_taxids, ch_groups)
    merged  = CONCATENATE_FASTA(genomes.fasta.collect())
    
    // 2. Indexing (Process handles skip logic internally if properly configured in module)
    index   = INDEX_GENOME(merged.fasta, params.index_name)

    // 3. Read Pre-processing (Low complexity filtering)
    filtered_reads = FILTER_READS(ch_reads)

    // 4. Mapping & Coverage Analysis
    align   = ALIGN_GENOME(filtered_reads, index.index_dir, params.index_name)
    covs    = GENERATE_COVERAGES(align.bam, merged.fasta)
    
    // 5. Final Statistics
    BREADTH_COVERAGE(covs, merged.fai)
}

/**
 * Robust Channel Creator for SE and PE reads
 * Uses glob patterns to handle paths correctly on any system
 */
def createMixedReadsChannel(reads_dir_path) {
   
    def ch_pe = Channel
        .fromFilePairs("${reads_dir_path}/*{_R,.R}{1,2}{.fastq,.fq}{.gz,}", checkIfExists: false)
        .map { id, files -> 
            [ [id: id, single_end: false], files ] 
        }

    // 2. More flexible pattern for Single-End
    def ch_se = Channel
        .fromPath("${reads_dir_path}/*.{fastq,fq}{.gz,}", checkIfExists: false)
        .filter { it.name.indexOf('_R1') == -1 && it.name.indexOf('_R2') == -1 &&
                  it.name.indexOf('.R1') == -1 && it.name.indexOf('.R2') == -1 }
        .map { file -> 
            [ [id: file.simpleName, single_end: true], file ] 
        }

<<<<<<< HEAD
    return ch_pe.mix(ch_se)
}
=======
    return Channel.from(items)
}




    
    // Check if genome index already exists
   // if ( file(params.index_dir).exists() ) {
   //     log.info ">>> Índice já existe em ${params.index_dir}, pulando etapa INDEX_GENOME"
   // }else {
   //     log.info ">>> Criando indice ${params.index_dir}..."
    //}
>>>>>>> d7b76a8df65a8d7cb5d83e873ecd4eb2d67a6b24
