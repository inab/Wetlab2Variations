class: CommandLineTool
cwlVersion: v1.0
id: BAM_index
baseCommand:
  - samtools
  - sort
  
requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: quay.io/biocontainers/samtools:1.3.1--5
  - class: ResourceRequirement
    outdirMin: 7500
    tmpdirMin: 7700
hints:
  - class: ResourceRequirement
    coresMin: 8
    ramMin: 8000

inputs:
  - id: input
    type: File
    inputBinding:
      position: 2
  - id: threads
    type: string?
    default: "8"
    inputBinding: 
      position: 1
      prefix: '--threads'
arguments:
  - position: 2
    prefix: '-o'
    valueFrom: $(inputs.input.nameroot).sorted.bam 
outputs:
  - id: sorted_bam
    type: File
    outputBinding:
      glob: "*.sorted.bam"
label: samtools-bam_sort
