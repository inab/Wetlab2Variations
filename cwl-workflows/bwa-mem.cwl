class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
baseCommand:
  - bwa
  - mem
  - -M
  - -p 
requirements:
  - class: InlineJavascriptRequirement
  - class: MultipleInputFeatureRequirement
  - class: DockerRequirement
    dockerPull: quay.io/biocontainers/bwa:0.7.17--h84994c4_5
  - class: ResourceRequirement
    outdirMin: 10500
    tmpdirMin: 10700
hints:
  - class: ResourceRequirement
    coresMin: 4
    ramMin: 4000
 
inputs:
#  - id: bwa_output_filename
#    type: string?
#    default: $(inputs.trimmed_fastq.nameroot).sam
  - id: trimmed_fastq
    type: File
    inputBinding:
      position: 4
      # Assume the first input query file is interleaved paired-end FASTA/Q. See the command description for details. 
  - id: reference_genome
    type: File
    inputBinding:
      position: 3
    secondaryFiles:
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
  - id: sample_name
    type: string
  - id: threads
    type: string?
    default: "2"
    inputBinding:
      position: 1
      prefix: '-t'
    doc: '-t INT        number of threads [1]'
  - id: read_group
    type: string
    default: '@RG\\tID:H947YADXX\\tSM:NA12878\\tPL:ILLUMINA'
    inputBinding: 
      position: 2
      prefix: -R
      
stdout: $(inputs.sample_name).sam
arguments:
  - position: 2
    prefix: -M
  - position: 2
    prefix: -p
 
outputs:
  - id: aligned_sam
    type: File
    outputBinding:
      glob: "*.sam"
