#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Operation
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
id: cutadapt2
label: cutadapt
requirements:
  - class: DockerRequirement
    dockerPull: 'quay.io/biocontainers/cutadapt:1.18--py36h14c3975_1'

inputs:
  - id: raw_sequences
    type: File[]
  - id: adaptors_file
    type: File?
outputs:  
  - id: trimmed_fastq
    type: File
