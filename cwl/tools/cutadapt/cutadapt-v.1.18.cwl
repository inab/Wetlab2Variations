class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
id: cutadapt2
baseCommand:
  - cutadapt
inputs:
  - id: raw_sequences
    type:
      - File
      - type: array
        items: File
    inputBinding:
      position: 2
      prefix: ''
      separate: false
  - id: trimmed_sequences
    type: string?
    inputBinding:
      position: 1
      prefix: '-o'
      valueFrom: '$(self? self : inputs.raw_sequences.basename + ".trimmed.fastq.gz")'
  - id: adaptors_file
    type: File?
    inputBinding:
      position: 0
      prefix: '-a'
outputs:
  - id: out_file
    type:
      - File
      - type: array
        items: File
    outputBinding:
      glob: $(inputs.trimmed_sequences)
label: cutadapt
arguments:
  - position: 0
    prefix: '--overlap'
    valueFrom: '6'
  - position: 0
    prefix: '--error-rate'
    valueFrom: '0.2'
requirements:
  - class: ScatterFeatureRequirement
  - class: InlineJavascriptRequirement
hints:
  - class: DockerRequirement
    dockerPull: 'cnag/cutadapt:1.18'
