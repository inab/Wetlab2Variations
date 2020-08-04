class: CommandLineTool
cwlVersion: v1.0
id: ir

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
    coresMin: 8
    ramMin: 8000

baseCommand:
  - java
  - -jar
  - /usr/GenomeAnalysisTK.jar
  - '-T'
  - IndelRealigner

inputs:
  - id: input
    type:
      - File
      - type: array
        items: File
    inputBinding:
      position: 2
      prefix: '-I'
    secondaryFiles:
      - ^.bai
  - id: rtc_intervals
    type: File
    inputBinding:
      position: 3
      prefix: '-targetIntervals'
  - id: reference_genome
    type: File
    inputBinding:
      position: 1
      prefix: '-R'
    secondaryFiles:
      - .fai
  - id: dict
    type: File

arguments:
  - position: 5
    prefix: '-dt'
    valueFrom: 'NONE'
  - position: 6
    prefix: '--maxReadsForRealignment'
    valueFrom: '200000'
  - position: 10
    prefix: '-o'
    valueFrom: $(inputs.input.nameroot).realigned.bam

outputs:
  - id: realigned_bam
    type: File
    outputBinding:
      glob: "*.realigned.bam"
    secondaryFiles:
      - ^.bai
    
label: ir
