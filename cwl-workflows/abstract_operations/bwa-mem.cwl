cwlVersion: v1.2
class: Operation
$namespaces:
  sbg: 'https://www.sevenbridges.com/'
requirements:
  - class: DockerRequirement
    dockerPull: quay.io/biocontainers/bwa:0.7.17--h84994c4_5
 
inputs:
#  - id: bwa_output_filename
#    type: string?
#    default: $(inputs.trimmed_fastq.nameroot).sam
  - id: trimmed_fastq
    type: File
      # Assume the first input query file is interleaved paired-end FASTA/Q. See the command description for details. 
  - id: reference_genome
    type: File
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
    doc: '-t INT        number of threads [1]'
  - id: read_group
    type: string
    default: '@RG\\tID:H947YADXX\\tSM:NA12878\\tPL:ILLUMINA'
       
outputs:
  - id: aligned_sam
    type: File
