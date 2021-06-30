cwlVersion: v1.2
class: Operation
id: picard_markduplicates
label: picard-MD
  
requirements:
  - class: DockerRequirement
    dockerPull: quay.io/biocontainers/picard:2.18.25--0

inputs:
  input:
    type: File

outputs:
  - id: md_bam
    type: File
    secondaryFiles:
     - ^.bai
  - id: output_metrics
    type: File

