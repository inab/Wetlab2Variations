cwlVersion: v1.2
class: CommandLineTool
id: gatk_haplotypecaller
label: gatk3-haplotypecaller

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
  # from gatk-base_recalibration_print_reads.cwl
  - id: input
    type: File
    secondaryFiles:
      - ^.bai
  # default is to analyse the complete genome
  - id: chromosome
    type: string?
  - id: ploidy
    type: int?
  - id: gqb
    type:
      - "null"
      - type: array
        items: int
  - id: threads
    type: string?
    default: "2"

outputs:
  - id: gvcf
    type: File
    secondaryFiles:
      #- .idx
      - .tbi