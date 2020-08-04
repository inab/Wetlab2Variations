cwlVersion: v1.0
class: CommandLineTool

doc: "transfer file from a remote FTP/HTTP server to the TES"
requirements:
#  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: jlaitinen/lftpalpine
  - class: ResourceRequirement
    coresMin: 2
    ramMin: 2000
    tmpdirMin: 7500
    outdirMin: 7500  
      
inputs:
  - id: curl_config_file
    type: File
    inputBinding:
      prefix: -K 
      separate: true
      position: 1
outputs:
  - id: raw_sequences
    type: File[]
    outputBinding:
      glob: "*.gz"

baseCommand: ["curl"]

 
