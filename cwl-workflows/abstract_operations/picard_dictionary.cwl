cwlVersion: v1.2
class: Operation
id: picard_dictionary
  
requirements:
  - class: DockerRequirement
    dockerPull: quay.io/biocontainers/picard:2.18.25--0

inputs:
  - id: reference_genome
    type: File

outputs:
  - id: dict
    type: File

 
