class: Workflow
cwlVersion: v1.0
id: rd_connect
label: RD_Connect
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
inputs:
  - id: raw_sequences
    type:
      - File
      - type: array
        items: File
    'sbg:x': -607
    'sbg:y': -208
  - id: reference
    type: File
    'sbg:x': -57
    'sbg:y': -641
  - id: rtc_intervals_name
    type: File
    'sbg:x': 275.60113525390625
    'sbg:y': -473.4110107421875
  - id: known_sites
    type:
      - File
      - type: array
        items: File
    'sbg:x': 360.4740905761719
    'sbg:y': -608.6580200195312
outputs:
  - id: output_metrics
    outputSource:
      - picard_markduplicates/output_metrics
    type: File
    'sbg:x': -26.121828079223633
    'sbg:y': -400.9543151855469
  - id: gvcf
    outputSource:
      - gatk3_haplotypecaller/gvcf
      - gatk3_haplotypecaller/br_model
    type: File
    'sbg:x': 1117.4185791015625
    'sbg:y': -162.47743225097656
steps:
  - id: cutadapt2
    in:
      - id: raw_sequences
        source:
          - raw_sequences
    out:
      - id: out_file
    run: tools/cutadapt/cutadapt-v.1.18.cwl
    label: cutadapt
    'sbg:x': -444.3984375
    'sbg:y': -209
  - id: bwa_mem
    in:
      - id: reads
        source:
          - cutadapt2/out_file
      - id: reference
        source: reference
    out:
      - id: output
    run: tools/bwa/bwa-mem.cwl
    'sbg:x': -229
    'sbg:y': -208
  - id: picard_markduplicates
    in:
      - id: input
        source:
          - bwa_mem/output
    out:
      - id: md_bam
      - id: output_metrics
    run: tools/picard/picard-v.2.18.25-markduplicates.cwl
    label: picard-MD
    'sbg:x': -29
    'sbg:y': -213
  - id: rtc
    in:
      - id: input
        source:
          - picard_markduplicates/md_bam
      - id: rtc_intervals_name
        source: rtc_intervals_name
      - id: reference_genome
        source: reference
    out:
      - id: rtc_intervals_file
    run: tools/gatk/gatk3-rtc.cwl
    label: rtc
    'sbg:x': 267
    'sbg:y': -224
  - id: ir
    in:
      - id: input
        source:
          - picard_markduplicates/md_bam
      - id: rtc_intervals
        source: rtc/rtc_intervals_file
      - id: reference_genome
        source: reference
    out:
      - id: realigned_bam
    run: tools/gatk/gatk3-ir.cwl
    label: ir
    'sbg:x': 276
    'sbg:y': -51
  - id: gatk3_base_recalibration
    in:
      - id: reference_sequence
        source: reference
      - id: input
        source:
          - ir/realigned_bam
      - id: known_sites
        source:
          - known_sites
    out:
      - id: br_model
    run: tools/gatk/gatk3-base_recalibration.cwl
    label: gatk3-base_recalibration
    'sbg:x': 623.4722290039062
    'sbg:y': -134.5416717529297
  - id: gatk3_base_recalibration_print_reads
    in:
      - id: reference_sequence
        source: reference
      - id: input
        source:
          - ir/realigned_bam
      - id: br_model
        source:
          - gatk3_base_recalibration/br_model
    out:
      - id: recalibrated_bam
    run: tools/gatk/gatk3-base_recalibration_print_reads.cwl
    label: gatk3-base_recalibration_print_reads
    'sbg:x': 773.4443969726562
    'sbg:y': 158.22222900390625
  - id: gatk3_haplotypecaller
    in:
      - id: reference_sequence
        source: reference
      - id: input
        source:
          - gatk3_base_recalibration_print_reads/recalibrated_bam
    out:
      - id: br_model
    run: tools/gatk/gatk3-haplotypecaller.cwl
    label: gatk3-haplotypecaller
    'sbg:x': 943.1527709960938
    'sbg:y': -166.19444274902344
requirements: []
