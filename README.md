# PhiFlow-DA

**A Nextflow pipeline for automated reference retrieval, low-complexity filtering, direct alignment, and breadth of coverage estimation.**

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A522.10.0-23aa62.svg)](https://www.nextflow.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🧬 Introduction

**PhiFlow-DA** (Direct Alignment) is a bioinformatics workflow designed to validate the presence of specific organisms (defaulting to viruses) in sequencing data. It is particularly useful for clinical diagnostics or metagenomic surveillance where you need to confirm if specific TaxIDs are present with a high degree of confidence.

The pipeline automates:
1.  **Reference Fetching**: Downloads genomes from NCBI based on User-provided TaxIDs or predefined groups.
2.  **Indexing**: Builds genomic indexes for the downloaded and concatenated references.
3.  **Low-Complexity Filtering**: Removes biased or "dust" reads to prevent non-specific mapping.
4.  **Read Mapping**: Automatically detects Single-End (SE) and Paired-End (PE) FASTQ files for alignment.
5.  **Coverage Profiling**: Calculates the **breadth of coverage** as a metric for genomic detection.

---

## 🚀 Quick Start

1. **Install Nextflow** (version 22.10.0 or higher):
   ```bash
   curl -s [https://get.nextflow.io](https://get.nextflow.io) | bash

2. Run the pipeline with the test dataset:
   ```bash
   nextflow run main.nf -profile test,conda

## 🛠 Usage
1. Basic usage
  ```bash
  nextflow run icaromsc/phiflow-da \
    --taxid_file <path_to_taxids> \
    --reads_dir <path_to_fastqs> \
    --outdir <results_directory>
  ```
2. Mandatory Parameters
   * --reads_dir: Path to the directory containing .fastq or .fastq.gz files. The pipeline automatically pairs files ending in _R1 and _R2.
   * --taxid_file: A plain text file with one NCBI TaxID per line (e.g., 11070).
     
3. Optional Parameters

  |Parameter| Description| Default|
  | --- | --- | --- |
  | --group | NCBI organism group if taxid_file is empty | viral |
  | --outdir | Path to the output directory| ./results |
  | --index_name | Prefix for the generated index | viral_index |
  | --breadth_threshold | "Min. threshold to consider a base ""covered"""| 0.1 |

## 🔄 Pipeline Summary

  The workflow executes the following modular steps:
  * **DOWNLOAD_GENOMES:** Automatically fetches FASTA sequences from NCBI using TaxIDs or group names.
  * **CONCATENATE_FASTA:** Merges individual genomic references into a single multi-FASTA file.
  * **INDEX_GENOME:** Builds the genomic index for the concatenated reference.
  * **FILTER_READS:** Filters low-complexity reads (e.g., simple repeats or low-entropy sequences) to minimize non-specific alignments and false positives.
  * **ALIGN_GENOME:** Performs direct mapping of filtered reads against the reference database.
  * **GENERATE_COVERAGES:** Processes alignments to produce sorted BAM files and per-base depth information.
  * **BREADTH_COVERAGE:** Calculates the percentage of the genome covered, providing a statistical validation of the presence of the organism.

## 📂 Output Directory Structure
Upon completion, results are organized as follows:
 ```Plaintext
results/
├── index/              # Reference index files
├── alignment/          # Sorted BAM and BAI files
├── filtered_reads/     # FASTQ files after low-complexity filtering
└── reports/            # Breadth of coverage calculations and summaries
```

## 📜 License

This pipeline is released under the MIT License.

## 👥 Credits

Developed by Icaro Castro (@icaromsc).  
