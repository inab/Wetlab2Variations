class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
id: picard_markduplicates
baseCommand:
  - picard
  - MarkDuplicates
inputs:
  - id: input
    type:
      - File
      - type: array
        items: File
    inputBinding:
      position: 2
      prefix: INPUT=
      separate: false
    secondaryFiles:
      - ^.bai
  - id: metrics_file
    type: string
    inputBinding:
      position: 1
      prefix: METRICS_FILE=
      separate: false
      valueFrom: $(inputs.sample).markduplicates.metrics
  - 'sbg:toolDefaultValue': $(inputs.sample).md.bam
    id: md_out
    type: string
    inputBinding:
      position: 3
      prefix: OUTPUT=
      separate: false
      valueFrom: $(inputs.sample).md.bam
    secondaryFiles:
      - .bai
  - id: sample
    type: string
outputs:
  - id: md_bam
    type: File
    outputBinding:
      glob: $(inputs.md_out)
    secondaryFiles:
      - ^.bai
  - id: output_metrics
    type: File
    outputBinding:
      glob: $(inputs.metrics_file)
label: picard-MD
arguments:
  - position: 0
    prefix: OPTICAL_DUPLICATE_PIXEL_DISTANCE=
    valueFrom: '100'
  - position: 0
    prefix: TAGGING_POLICY=
    valueFrom: All
  - position: 0
    prefix: CREATE_INDEX=
    valueFrom: 'true'
  - position: 0
    prefix: REMOVE_DUPLICATES=
    valueFrom: 'true'
hints:
  - class: DockerRequirement
    dockerPull: 'cnag/picard:2.18.25'
requirements:
  - class: InlineJavascriptRequirement
