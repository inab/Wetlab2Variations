class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
id: rtc
baseCommand:
  - gatk
  - '-T'
  - RealignerTargetCreator
inputs:
  - id: input
    type:
      - File
      - type: array
        items: File
    inputBinding:
      position: 2
      prefix: '-I'
  - id: rtc_intervals_name
    type: File
    inputBinding:
      position: 3
      prefix: '-O'
  - id: reference_genome
    type: File
    inputBinding:
      position: 1
      prefix: '-R'
  - id: known_indels
    type:
      - 'null'
      - File
      - type: array
        items: File
    inputBinding:
      position: 4
      prefix: '--known'
outputs:
  - id: rtc_intervals_file
    type: File?
label: rtc
arguments:
  - position: 5
    prefix: '-dt'
    valueFrom: NONE
