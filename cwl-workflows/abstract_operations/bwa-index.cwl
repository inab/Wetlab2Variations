cwlVersion: v1.2
class: Operation

requirements:
  - class: DockerRequirement
    dockerPull: quay.io/biocontainers/bwa:0.7.17--h84994c4_5

inputs:
  algorithm:
    type: string?
    doc: |
       BWT construction algorithm: bwtsw or is (Default: auto)
  reference_genome:
    type: File
  block_size:
    type: int?

outputs:
  output:
    type: File
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa

