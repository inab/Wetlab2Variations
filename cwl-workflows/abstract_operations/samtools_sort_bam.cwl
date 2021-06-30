cwlVersion: v1.2
class: Operation
id: BAM_index
label: samtools-bam_sort
  
requirements:
  - class: DockerRequirement
    dockerPull: quay.io/biocontainers/samtools:1.3.1--5

inputs:
  - id: input
    type: File
  - id: threads
    type: string?
    default: "8"
outputs:
  - id: sorted_bam
    type: File