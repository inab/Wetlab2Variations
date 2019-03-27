class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
id: gatk3_base_recalibration_print_reads
baseCommand:
  - gatk
  - '-T'
  - PrintReads
inputs:
  - id: reference_sequence
    type: File
    inputBinding:
      position: 1
      prefix: '-R'
    secondaryFiles:
      - .fai
      - ^.dict
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
  - id: output_filename
    type: string
    inputBinding:
      position: 3
      prefix: '-o'
  - id: br_model
    type:
      - File
      - type: array
        items: File
    inputBinding:
      position: 4
      prefix: '-BQSR'
outputs:
  - id: recalibrated_bam
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
label: gatk3-base_recalibration_print_reads
arguments:
  - position: 0
    prefix: '-dt'
    valueFrom: NONE
requirements:
  - class: InlineJavascriptRequirement
  - $import: gatk3-docker.yml