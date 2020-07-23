- nextflow.config contains information regarding:

    - Containers to be used.
    - Report files to be produced and their paths.

- nextflow.nf contains:
    
    - Definition of params accepted by the workflow.
    - Wrapper of params accepted by the workflow on CMD:
    
        - ProcessUserInputedArguments. Entrypoint that transforms CMD params (--paramname) into params structure.
        - printSection. Used by PrintConfiguration to allow several levels inside the workflow params-file.
        - PrintConfiguration. Method that reports the current params.
        - parseElement. Method that transforms an entry to JSON format. Makes use of recursion to handle JSON levels.
        - SaveParamsToFile. Method to save the current params to a file.

        This methods are called in this form:
        
        - ProcessUserInputedArguments() - Process and clean user inputed arguments.
        - SaveParamsToFile() - Save them to a param-file.
        - PrintConfiguration() - Print the current configuration.
            
    - Code to allow inputting Genome Indexes: 
        
        Several channels represent the Genome Indexes. As they can be provided or generated, three sets of channels are created:
        
        - Produced
        - Provided
        - Final
        
        If provided are populated, and all files are present, produced are empty channels. Otherwise, the empty channels are the produced.
        Final channels is the mix and first of both previous channels. This allow to use it as a singleton (reusable) channel, while handling both situations.
        
    - Processes of the workflow
    
    To have a better insight of what steps are related to others, the DAG file in results (after a successful execution) provides the relation between steps and channels. 
    This file can be converted using "dot -Tpng results/DAG.dot -o DAG.png".
    
    To download the files needed to execute the pipeline, there is a script in the ../test folder which downloads them using curl.
    Two of those files need to provide an 'anonymous' user with empty password. This is handled by the script.
    
    So, in recap, the steps to easily test the workflow is:
    
    - Have nextflow installed.
    - Download input files by using 'DownloadSources.sh' in the ../test folder.
    - Execute './nextflow.nf'
    - Wait for results.
