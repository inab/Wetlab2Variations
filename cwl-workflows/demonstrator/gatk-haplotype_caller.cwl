cwlVersion: v1.0
class: CommandLineTool
id: gatk_haplotypecaller

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
  - HaplotypeCaller
  - --never_trim_vcf_format_field

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
  # from gatk-base_recalibration_print_reads.cwl
  - id: input
    type: File
    inputBinding:
      position: 2
      prefix: '-I'
    secondaryFiles:
      - ^.bai
  # default is to analyse the complete genome
  - id: chromosome
    type: string?
    inputBinding:
      position: 3
      prefix: '-L'
  - id: ploidy
    type: int?
    inputBinding:
      position: 5
      prefix: '-ploidy'
  - id: gqb
    type:
      - "null"
      - type: array
        items: int
        inputBinding: { prefix: "--GVCFGQBands" }
    inputBinding:
      position: 12
  - id: threads
    type: string?
    default: "2"

arguments:
  - position: 0
    prefix: '--num_cpu_threads_per_data_thread'
    valueFrom: $(inputs.threads) 
  - position: 0
    prefix: '-dt'
    valueFrom: 'NONE'
  - position: 0
    prefix: '-rf'
    valueFrom: 'BadCigar'
  - position: 0
    prefix: '-ERC'
    valueFrom: 'GVCF'
  - position: 0
    prefix: '-variant_index_type'
    valueFrom: 'LINEAR'
  - position: 0
    prefix: '-variant_index_parameter'
    valueFrom: '128000'
  - position: 0
    prefix: '-o'
    valueFrom: $(inputs.input.nameroot).vcf.gz

outputs:
  - id: gvcf
    type: File
    outputBinding:
      glob: "*.gz"
    secondaryFiles:
      #- .idx
      - .tbi

label: gatk3-haplotypecaller


