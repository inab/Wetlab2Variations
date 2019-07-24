class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
id: ir
baseCommand:
  - gatk
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
  - id: realigned_bam_name
    type: File?
    inputBinding:
      position: 3
      prefix: '-O'
outputs:
  - id: realigned_bam
    type: File
    secondaryFiles:
      - ^.bai

label: ir
arguments:
  - position: 5
    prefix: '-dt'
    valueFrom: 'NONE'
  - position: 6
    prefix: '-maxReadsForRealignment'
    valueFrom: '200000'
