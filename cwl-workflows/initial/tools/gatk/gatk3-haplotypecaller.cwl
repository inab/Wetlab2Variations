class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
id: gatk3_haplotypecaller
baseCommand:
  - gatk
  - '-T'
  - HaplotypeCaller
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
      - .bai
  - id: chromosome
    type: string
    inputBinding:
      position: 3
      prefix: '-L'
  - id: output_filename
    type: string
    inputBinding:
      position: 4
      prefix: '-o'
#  - 'sbg:toolDefaultValue': '2'
#    id: ploidy
#    type: int?
#    inputBinding:
#      position: 4
#      prefix: '-ploidy'
outputs:
  - id: br_model
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
    secondaryFiles:
      - .tbi
label: gatk3-haplotypecaller
arguments:
  - position: 0
    prefix: '-dt'
    valueFrom: NONE
  - position: 0
    prefix: '-rf'
    valueFrom: BadCigar
  - position: 0
    prefix: '-ERC'
    valueFrom: GVCF
  - position: 0
    prefix: ''
    valueFrom: '--never_trim_vcf_format_field'
requirements:
  - class: InlineJavascriptRequirement
  - $import: gatk3-docker.yml
