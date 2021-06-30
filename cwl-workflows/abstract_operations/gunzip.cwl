cwlVersion: v1.2
class: Operation

requirements:
  - class: DockerRequirement
    dockerPull: jlaitinen/lftpalpine

inputs:
  - id: reference_file
    type: File[]
outputs:
  - id: unzipped_fasta
    type: File
