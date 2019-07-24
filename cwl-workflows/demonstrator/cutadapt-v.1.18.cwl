#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.0
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
id: cutadapt2
requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: 'cnag/cutadapt:1.18'
  - class: ResourceRequirement
    outdirMin: 2500
    tmpdirMin: 2500
hints:
  - class: ResourceRequirement
    coresMin: 4
    ramMin: 4000

baseCommand: [cutadapt, --interleaved]
arguments: 
  - position: 4
    prefix: '-o'
    valueFrom: '$(inputs.raw_sequences[0].basename + ".trimmed.fastq.gz")' 
  - position: 3
    prefix: '--overlap'
    valueFrom: '6'
  # automatic threads
  - position: 1
    prefix: '-j'
    valueFrom: '0'
  - position: 2
    prefix: '--error-rate'
    valueFrom: '0.2'
inputs:
  - id: raw_sequences
    type: File[]
    inputBinding:
      position: 20
      prefix: ''
      separate: false
  - id: adaptors_file
    type: File?
    inputBinding:
      position: 10
      prefix: '-a'
outputs:  
  - id: trimmed_fastq
    type: File
    outputBinding:
      glob: '*.trimmed.fastq.gz'
label: cutadapt
