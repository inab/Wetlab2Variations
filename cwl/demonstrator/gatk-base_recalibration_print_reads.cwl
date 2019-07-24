cwlVersion: v1.0
class: CommandLineTool
id: gatk_base_recalibration_print_reads

requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: broadinstitute/gatk3:3.6-0
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.reference_genome)
      - entry: $(inputs.dict)
      - entry: $(inputs.br_model)
  - class: ResourceRequirement
    outdirMin: 7500
    tmpdirMin: 7700

hints:
  - class: ResourceRequirement
    coresMin: 8
    ramMin: 8000

baseCommand:
  - java
  - -jar
  - /usr/GenomeAnalysisTK.jar
  - '-T'
  - PrintReads

inputs:
  - id: reference_genome
    type: File
    inputBinding:
      position: 1
      prefix: '-R'
    secondaryFiles:
      - .fai
  - id: dict
    type: File
  - id: input
    type:
      - File
    inputBinding:
      position: 2
      prefix: '-I'
    secondaryFiles:
      - ^.bai
  - id: br_model
    type:
      - File
    inputBinding:
      position: 4
      prefix: '-BQSR'

arguments:
  - position: 0
    prefix: '-dt'
    valueFrom: 'NONE'
  - position: 3
    prefix: '-o'
    valueFrom: $(inputs.input.nameroot).bqsr.bam

outputs:
  - id: bqsr_bam
    type: File
    outputBinding:
       glob: $(inputs.input.nameroot).bqsr.bam
    secondaryFiles:
      - ^.bai

label: gatk-base_recalibration_print_reads

