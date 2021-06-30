cwlVersion: v1.2
class: Operation
id: gatk-base_recalibration
label: gatk3-base_recalibration

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
  - id: unzipped_known_sites_file
    type: File
  # from gatk ir
  - id: input
    type: File
    secondaryFiles:
      - ^.bai
  - id: known_indels_file
    type: File
  - id: threads
    type: string?

outputs:
  - id: br_model
    type: File
