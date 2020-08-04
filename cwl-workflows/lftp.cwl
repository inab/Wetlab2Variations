cwlVersion: v1.0
class: CommandLineTool

doc: "transfer file passed from the previous task to the remote ftp server"
requirements:
  - class: InlineJavascriptRequirement 
  - class: DockerRequirement
    dockerPull: jlaitinen/lftpalpine
  - class: MultipleInputFeatureRequirement
  - class: InitialWorkDirRequirement
    listing: ${
        var r = [];
        for (var i=0; i < inputs.files_to_send.length; i++) {
          r.push(inputs.files_to_send[i]);
        }
        r.push(inputs.gvcf);
        r.push(inputs.bam);
        return r; 
      }
  - class: ResourceRequirement
    outdirMin: 7200
hints:
  - class: ResourceRequirement
    coresMin: 1 
    ramMin: 2000
    
inputs:
  - id: lftp_out_conf
    type: File
    doc: "The parameters file for lftp"
    inputBinding:
      position: 1
  - id: files_to_send
    type:
      type: array
      items: File
  - id: bam
    type: File
    secondaryFiles: 
      - ^.bai
  - id: gvcf
    type: File
    secondaryFiles:
      - .tbi

#      inputBinding:
#        valueFrom: $(self.basename)
outputs:
  - id: output
    type: stdout

baseCommand: ["lftp"]
arguments: ["-f"]
 
