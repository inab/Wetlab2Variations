class: CommandLineTool

cwlVersion: v1.0

baseCommand: [ "gunzip" ]

arguments: [ "-c" ]

requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: jlaitinen/lftpalpine
  - class: ResourceRequirement
    coresMin: 2
    ramMin: 2000
    outdirMin: 12500
    tmpdirMin: 12500

inputs:
  - id: input
    type: File
    inputBinding:
      position: 1

outputs:
  - id: output
    type: stdout
    #outputBinding:
    #  glob: "*.gvcf"
stdout: $(inputs.input.nameroot)
