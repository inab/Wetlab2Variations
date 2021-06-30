cwlVersion: v1.2
class: Operation
id: gatk_base_recalibration_print_reads
label: gatk-base_recalibration_print_reads

requirements:
  - class: DockerRequirement
    dockerPull: broadinstitute/gatk3:3.6-0

inputs:
  - id: reference_genome
    type: File
    secondaryFiles:
      - .fai
  - id: dict
    type: File
  - id: input
    type:
      - File
    secondaryFiles:
      - ^.bai
  - id: br_model
    type:
      - File

outputs:
  - id: bqsr_bam
    type: File
    secondaryFiles:
      - ^.bai