cwlVersion: v1.2
class: Operation
id: fastq_index
label: samtools-faidx
  
requirements:
  - class: DockerRequirement
    dockerPull: quay.io/biocontainers/samtools:1.3.1--5

inputs:
  - id: input
    type: File

outputs:
  - id: index_fai
    type: File
    secondaryFiles:
      - .fai

