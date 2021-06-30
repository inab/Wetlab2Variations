cwlVersion: v1.2
class: Operation

requirements:
  - class: DockerRequirement
    dockerPull: jlaitinen/lftpalpine

inputs:
  - id: input
    type: File

outputs:
  - id: output
    type: File
