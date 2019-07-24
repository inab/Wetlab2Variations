cwlVersion: v1.0
class: CommandLineTool
id: gatk-base_recalibration

requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: broadinstitute/gatk3:3.6-0
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.reference_genome)
      - entry: $(inputs.dict)
  - class: ResourceRequirement
    outdirMin: 7500
    tmpdirMin: 7700

hints:
  - class: ResourceRequirement
    coresMin: 4
    ramMin: 4000

baseCommand:
  - java 
  - -jar
  - /usr/GenomeAnalysisTK.jar
  - '-T'
  - BaseRecalibrator

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
  - id: unzipped_known_sites_file
    type: File
  # from gatk ir
  - id: input
    type: File
    inputBinding:
      position: 2
      prefix: '-I'
    secondaryFiles:
      - ^.bai
  - id: known_indels_file
    type: File
  - id: threads
    type: string?

arguments:
  - position: 0
    prefix: '-dt'
    valueFrom: NONE
  - position: 0
    prefix: '-nct'
    valueFrom: $(inputs.threads)
  - position: 0
    prefix: '--knownSites'
    valueFrom: $(inputs.known_indels_file)
  - position: 0
    prefix: '--knownSites'
    valueFrom: $(inputs.unzipped_known_sites_file)
  - position: 3
    prefix: '-o'
    valueFrom: $(inputs.input.nameroot).recalibrated.grp

outputs:
  - id: br_model
    type: File
    outputBinding:
      glob: "*.grp"

label: gatk3-base_recalibration

