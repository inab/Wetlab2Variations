cwlVersion: v1.0
class: CommandLineTool
baseCommand: ["curl"]

doc: "transfer file from a remote FTP/HTTP server to the TES"
requirements:
  - class: DockerRequirement
    dockerPull: jlaitinen/lftpalpine
  - class: ResourceRequirement
    tmpdirMin: 2500
    outdirMin: 2500  
hints:
  - class: ResourceRequirement
    coresMin: 2
    ramMin: 2000
      
inputs:
  curl_config_file:
    type: File
    inputBinding:
      prefix: -K 
      separate: true
      position: 1

outputs:
  known_sites_file:
    type: File
    outputBinding:
      glob: "*.gz"
 
