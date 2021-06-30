cwlVersion: v1.2
class: Operation
id: ir
label: ir

requirements:
  - class: DockerRequirement
    dockerPull: broadinstitute/gatk3:3.6-0

inputs:
  - id: input
    type:
      - File
      - type: array
        items: File
    secondaryFiles:
      - ^.bai
  - id: rtc_intervals
    type: File
  - id: reference_genome
    type: File
    secondaryFiles:
      - .fai
  - id: dict
    type: File

outputs:
  - id: realigned_bam
    type: File
    secondaryFiles:
      - ^.bai