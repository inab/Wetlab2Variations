cwlVersion: v1.2
class: Operation
id: rtc
label: rtc 

requirements:
  - class: DockerRequirement
    dockerPull: broadinstitute/gatk3:3.6-0

inputs:
  - id: input
    type: File
    secondaryFiles:
      - ^.bai
   # must have .list
  - id: rtc_intervals_name
    type: string? 
    default: 'rtc_intervals.list'
  - id: reference_genome
    type: File
    secondaryFiles:
      - .fai
  - id: known_indels
    type: File
  - id: dict
    type: File
      
outputs:
  - id: rtc_intervals_file
    type: File
