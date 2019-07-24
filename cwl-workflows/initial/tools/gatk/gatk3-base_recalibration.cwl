class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
id: gatk3_base_recalibration
baseCommand:
  - gatk
  - '-T'
  - BaseRecalibrator
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
#      - .bai
      - ^.bai
  - id: output_filename
    type: string
    inputBinding:
      position: 3
      prefix: '-o'
  - id: known_sites
    type:
      - File
      - type: array
        items: File
    inputBinding:
      position: 4
      prefix: '--knownSites'
outputs:
  - id: br_model
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
label: gatk3-base_recalibration
arguments:
  - position: 0
    prefix: '-dt'
    valueFrom: NONE
requirements:
  - class: InlineJavascriptRequirement
  - $import: gatk3-docker.yml