#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
# id: rd_connect
label: RD_Connect

inputs:
  - id: fastq_files
    type: File[]
  - id: reference_genome
    type: File[]
  - id: known_indels_file
    type: File
  - id: known_sites_file
    type: File
  - id: chromosome
    # type: string?
    type: string
  - id: readgroup_str
    type: string
  - id: sample_name
    type: string

outputs: 
  - id: metrics
    outputSource:
     - picard_markduplicates/output_metrics
    type: File
  - id: gvcf
    outputSource:
     - gatk_haplotype_caller/gvcf
    type: File

steps:

  - id: unzipped_known_sites
    in:
      - id: known_sites_file
        source:
          - known_sites_file
    out:
      - id: unzipped_known_sites_file
    run: gunzip_known_sites.cwl

  - id: gunzip
    in:
      - id: reference_file
        source:
          - reference_genome
    out:
      - id: unzipped_fasta
    run: gunzip.cwl

  - id: picard_dictionary
    # from samtools reference genome
    in:
      - id: reference_genome
        source:
          - gunzip/unzipped_fasta
    # produced .dict file
    out:
      - id: dict
    run: picard_dictionary.cwl

  - id: cutadapt2
    in:
      - id: raw_sequences
        source:
          - fastq_files
    out: 
      - id: trimmed_fastq
    run: cutadapt-v.1.18.cwl

  - id: bwa_index
    in:
      - id: reference_genome
        source:
          - gunzip/unzipped_fasta
    out:
      - id: output
    run: bwa-index.cwl

  - id: samtools_index
    in:
      - id: input
        source:
          - gunzip/unzipped_fasta
    out:
      - id: index_fai
    run: samtools_index.cwl


  - id: bwa_mem
    in:

      - id: sample_name
        source:
          - sample_name
      - id: trimmed_fastq
        source:
         - cutadapt2/trimmed_fastq
      - id: read_group
        source:
          - readgroup_str
      - id: reference_genome
        source:
          - bwa_index/output
    out:
      - id: aligned_sam
    run: bwa-mem.cwl

  - id: samtools_sort
    in:
      - id: input
        source:
          - bwa_mem/aligned_sam
    out:
      - id: sorted_bam
    run: samtools_sort_bam.cwl
   
  - id: picard_markduplicates
    in:
      - id: input
        source: 
          - samtools_sort/sorted_bam
    out:
      - id: md_bam
      - id: output_metrics
    run: picard_markduplicates.cwl
    label: picard-MD


  - id: gatk3-rtc
    in:
      - id: input
        source: 
          - picard_markduplicates/md_bam
      - id: reference_genome
        source: 
          - samtools_index/index_fai
      - id: dict
        source:
          - picard_dictionary/dict
      - id: known_indels
        source:
          - known_indels_file
    out:
      - id: rtc_intervals_file
    run: gatk3-rtc.cwl
    label: gatk3-rtc

  - id: gatk-ir
    in:
      - id: input
        source: 
          - picard_markduplicates/md_bam
      - id: rtc_intervals
        source: 
          - gatk3-rtc/rtc_intervals_file
      - id: reference_genome
        source: 
           - samtools_index/index_fai
      - id: dict
        source:
          - picard_dictionary/dict
    out:
      - id: realigned_bam
    run: gatk-ir.cwl
    label: gatk-ir

  - id: gatk-base_recalibration
    in:
      - id: reference_genome
        source: 
          - samtools_index/index_fai
      - id: dict
        source:
          - picard_dictionary/dict
      - id: input
        source:
          - gatk-ir/realigned_bam
      - id: unzipped_known_sites_file
        source:
          - unzipped_known_sites/unzipped_known_sites_file
      - id: known_indels_file
        source:
          - known_indels_file
    out:
      - id: br_model 
    run: gatk-base_recalibration.cwl
    label: gatk-base_recalibration

  - id: gatk-base_recalibration_print_reads
    in:
      - id: reference_genome
        source: 
          - samtools_index/index_fai
      - id: dict
        source:
          - picard_dictionary/dict
      - id: input
        source:
          - gatk-ir/realigned_bam
      - id: br_model
        source:
          - gatk-base_recalibration/br_model
    out:
      - id: bqsr_bam
    run: gatk-base_recalibration_print_reads.cwl
    label: gatk-base_recalibration_print_reads


  - id: gatk_haplotype_caller
    in:
      - id: reference_genome
        source: 
          - samtools_index/index_fai
      - id: dict
        source:
          - picard_dictionary/dict
      - id: input
        source:
          - gatk-base_recalibration_print_reads/bqsr_bam
      - id: chromosome
        source: 
          - chromosome
    out:
      - id: gvcf
    run: gatk-haplotype_caller.cwl
    label: gatk-haplotype_caller

requirements:
  - class: MultipleInputFeatureRequirement
