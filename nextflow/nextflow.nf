#!/usr/bin/env nextflow

// Default param values have been moved to nextflow.config
reference = file(params.general.referencegenome)

// Channels
Channel
    .fromPath(params.general.rawreads)
    .set { samples_ch }

Channel
    .fromPath( params.BSQR.files )
    .set { knownSitesCh }


void ProcessUserInputedArguments()
{
    def toRemove = []
    // Detect user inputed arguments.
    // Param's values are all dictionaries, whose class is null
    // User inputed arguments always(?) have classes associated
    for (param in params) 
        if (param.value.class != null)
            toRemove.add(param.key)

    // Transform the user inputed arguments into params
    for (userArgument in toRemove) {

        // Split the name into a list of entries, 
        // which represent a hierarchy inside params
        splittedArgument = userArgument.split('\\.')

        // Traverse the hierarchy starting from params
        curDict = params
        partOfConfiguration = true

        if (splittedArgument.size() > 1) {
            int x = 0;
            // For each hierarchy level in the hierarchy obtained (but last element)
            for (; x < (splittedArgument.size() - 1); x++) {

                // Get the current hierarchy level
                hierarchy = splittedArgument[x]

                // Check if the current hierarchy dict contains the current level as key
                // This is useful to inform the user of misspelled arguments
                if (curDict.containsKey(hierarchy))
                {
                    if (curDict[hierarchy] != null && curDict[hierarchy].class == null)
                    {
                        // Move deeper inside the hierarchy
                        curDict = curDict[hierarchy]    
                        continue  
                    }
                }

                // If current hierarchy dict does not contain the current level, inform the user
                println "[Config Wrapper] Argument \"" + userArgument + "\" is not part of the configuration"

                // Reverse the flag params from containing wrong information
                partOfConfiguration = false
                break
            }

            if (x == splittedArgument.size() - 1) {
                // Check if we have to change a value in params
                if (partOfConfiguration && curDict.containsKey(splittedArgument[x])) {
                    println "[Config Wrapper] " + userArgument + " new value: " + params[userArgument] 
                    curDict[splittedArgument[splittedArgument.size() - 1]] = params[userArgument]
                } else {
                    println "[Config Wrapper] Argument \"" + userArgument + "\" is not part of the configuration\n" +
                            "                 \"" + splittedArgument[x] + "\" is not an element of \"" + splittedArgument[x - 1] + "\"" 
                }
            }
        } 
        else 
            println "[Config Wrapper] Argument \"" + userArgument + "\" is not part of the configuration"
        
        params.remove(userArgument)
    }
}

void printSection(section, level = 1)
{
    println (("  " * level) + "↳ " + section.key)
    if (section.value.class == null)
    {
        for (element in section.value)
        {
            printSection(element, level + 1)
        }
    }
    else {
        if (section.value == "")
            println (("  " * (level + 1) ) + "↳ Empty String")
        else
            println (("  " * (level + 1) ) + "↳ " + section.value)
    }
}

void PrintConfiguration()
{
    println ""
    println "=" * 34
    println "Wet Lab 2 Variations Configuration"
    println "=" * 34

    for (configSection in params) {
        printSection(configSection)
        println "=" * 30
    }

    println "\n"
}

String parseElement(element)
{
    if (element instanceof String || element instanceof GString ) 
        return "\"" + element + "\""    

    if (element instanceof Integer)
        return element.toString()

    if (element.value.class == null)
    {
        StringBuilder toReturn = new StringBuilder()
        toReturn.append()
        toReturn.append("\"")
        toReturn.append(element.key)
        toReturn.append("\": {")

        for (child in element.value)
        {
            toReturn.append(parseElement(child))
            toReturn.append(',')
        }
        toReturn.delete(toReturn.size() - 1, toReturn.size() )
        
        toReturn.append('}')
        return toReturn.toString()
    } 
    else 
    {
        if (element.value instanceof String || element.value instanceof GString ) 
            return "\"" + element.key + "\": \"" + element.value + "\""            

        else if (element.value instanceof ArrayList)
        {
            // println "\tis a list"
            StringBuilder toReturn = new StringBuilder()
            toReturn.append("\"")
            toReturn.append(element.key)
            toReturn.append("\": [")
            for (child in element.value)
            {
                toReturn.append(parseElement(child)) 
                toReturn.append(",")                
            }
            toReturn.delete(toReturn.size() - 1, toReturn.size() )
            toReturn.append("]")
            return toReturn.toString()
        }

        return "\"" + element.key + "\": " + element.value
    }
}

def SaveParamsToFile() 
{
    // Check if we want to produce the params-file for this execution
    if (params.general.paramsout == null || params.general.paramsout == "")
        return;

    // Replace the strings ${baseDir} and ${workflow.runName} with their values
    params.general.paramsout = params.general.paramsout
        .replace("\${baseDir}".toString(), baseDir.toString())
        .replace("\${workflow.runName}".toString(), workflow.runName.toString())

    // Store the provided paramsout value in usedparamsout
    params.general.usedparamsout = params.general.paramsout

    // Compare if provided paramsout is the default value
    if ( params.general.paramsout == "${baseDir}/param-files/${workflow.runName}.json")
    {
        // And store the default value in paramsout
        params.general.paramsout = "\${baseDir}/param-files/\${workflow.runName}.json"
    }

    // Inform the user we are going to store the params-file and how to use it.
    println "[Config Wrapper] Saving current parameters to " + params.general.usedparamsout + "\n" +
            "                 This file can be used to input parameters providing \n" + 
            "                   '-params-file \"" + params.general.usedparamsout + "\"'\n" + 
            "                   to nextflow when running the workflow."


    // Manual JSONification of the params, to avoid using libraries.
    StringBuilder content = new StringBuilder();
    // Start the dictionary
    content.append("{")

    // As parseElement only accepts key-values or dictionaries,
    //      we iterate here for each 'big-category'
    for (element in params) 
    {
        // We parse the element
        content.append(parseElement(element))
        // And add a comma to separate elements of the list
        content.append(",")
    }

    // Remove the last comma
    content.delete(content.size() - 1, content.size() )
    // And add the final bracket
    content.append("}")

    // Create a file handler for the current usedparamsout
    configJSON = file(params.general.usedparamsout)
    // Make all the dirs of usedparamsout path
    configJSON.getParent().mkdirs()
    // Write the contents to file
    configJSON.write(content.toString())
}

println ""
ProcessUserInputedArguments()
SaveParamsToFile()
PrintConfiguration()

// Processes
process adaptorRemoval {
	tag "Adaptor removal"
	container "quay.io/biocontainers/cutadapt:1.18--py36h14c3975_1"

	input: 
		set file(read1), file(read2) from samples_ch.collect()

	output:
		file "*.noAdaptor.fastq.gz" into cleanedReads

	script:
	// Create variables to apply, or not, several parameters
		
    // Create a variable to apply an adaptor file
    def adaptorArgument = (params.cutadapt.adapter != null && params.cutadapt.adapter != "")
        ? "-a ${params.cutadapt.adapterFile} " 	: ''


    if (params.cutadapt.adapterfile != null && params.cutadapt.adapterfile != "")
    {
        adapterfile = file(params.cutadapt.adapterfile)
        adapters = adapterfile.readLines()
        for(adapter in adapters)
        {
            if (adapter[0] != '-') adaptorArgument += "-a " + adapter + " "
            else adaptorArgument += adapter + " "
        }
    }

    // Create a variable to use several cores on this step
    def cutadaptcoresArgument = (params.cutadapt.cores != null && params.cutadapt.cores != 1)
        ? "-j ${params.cutadapt.cores}" : ''

	"""
	cutadapt \
                    ${adaptorArgument} \
                    ${cutadaptcoresArgument} \
                    ${params.cutadapt.extraargs} \
    --output        ${read1.baseName}.noAdaptor.fastq.gz \
    --paired-output ${read2.baseName}.noAdaptor.fastq.gz \
    $read1 $read2
	"""
}

def providedReferenceGenomeIndex = false
if (params.general.itermediate?.referencegenomeindexpath != null && params.general.itermediate.referencegenomeindexpath != '')
{
    files = new ArrayList()
    for(extension in ["amb", "ann", "bwt", "pac", "sa"])
    {
        File tmp = new File(params.general.itermediate.referencegenomeindexpath + "/" + reference.name + "." + extension)
        if(tmp.exists())
            files += tmp
    }

    if (files.size == 5) 
    {
        Channel.fromPath(files[0]).set{provided_index_amb}
        Channel.fromPath(files[1]).set{provided_index_ann}
        Channel.fromPath(files[2]).set{provided_index_bwt}
        Channel.fromPath(files[3]).set{provided_index_pac}
        Channel.fromPath(files[4]).set{provided_index_sa}
        providedReferenceGenomeIndex = true
        println "Skipping Genome Indexing as indexes have been provided"
    }
}

if (!providedReferenceGenomeIndex) {
    Channel.empty().set{provided_index_amb}
    Channel.empty().set{provided_index_ann}
    Channel.empty().set{provided_index_bwt}
    Channel.empty().set{provided_index_pac}
    Channel.empty().set{provided_index_sa}
}

process referenceGenomeIndexing {
	tag "Genome Indexing"
	container "quay.io/biocontainers/bwa:0.7.17--h84994c4_5"

    when:
        !providedReferenceGenomeIndex

	input: 
		file reference

	output:
	    file "${reference.name}.amb" into produced_index_amb
	    file "${reference.name}.ann" into produced_index_ann
	    file "${reference.name}.bwt" into produced_index_bwt
	    file "${reference.name}.pac" into produced_index_pac
	    file "${reference.name}.sa"  into produced_index_sa
        
	script:
	// Create variables to apply, or not, several parameters
    // Create a variable to use several cores on this step
    def bwablocksize = (params.bwaindex.blocksize != null && params.bwaindex.blocksize != "")
        ? "-b ${params.bwaindex.blocksize}" : ""

	"""
	bwa index -a bwtsw ${bwablocksize} $reference 
	"""
}

// Create final channels for the indexes.
// Using the values of produced and/or provided indexes.
// There should only be one element per channel, but is not Singleton Channel by default.
// We use first() to convert a Queue Channel to a Singleton Channel
produced_index_amb  .mix(provided_index_amb)    .first()    .set{final_index_amb}
produced_index_ann  .mix(provided_index_ann)    .first()    .set{final_index_ann}
produced_index_bwt  .mix(provided_index_bwt)    .first()    .set{final_index_bwt}
produced_index_pac  .mix(provided_index_pac)    .first()    .set{final_index_pac}
produced_index_sa   .mix(provided_index_sa)     .first()    .set{final_index_sa}

process genomeMapping {
	tag "Genome Mapping"
	container "quay.io/biocontainers/bwa:0.7.17--h84994c4_5"

	input: 
		file reference
		file "${reference.name}.amb" from final_index_amb
        file "${reference.name}.ann" from final_index_ann
		file "${reference.name}.bwt" from final_index_bwt
		file "${reference.name}.pac" from final_index_pac
		file "${reference.name}.sa"  from final_index_sa 

		set file(read1), file(read2) from cleanedReads.collect()

	output:
		file "${reference.name}.sam" into bwa_mapped

	script:
	// Create variables to apply, or not, several parameters
    // Create a variable to use several cores on this step
    def bwacoresArgument 	= (params.bwamem.cores != null && params.bwamem.cores != 1)
        ? "-t ${params.bwamem.cores}" : ''

	"""
	bwa mem -R "${params.bwamem.rgheader}" -M ${bwacoresArgument} ${reference.name} ${read1} ${read2} > ${reference.name}.sam
	"""
}

process samToBam {
	tag "Sam to Bam"
	container "quay.io/biocontainers/sambamba:0.6.8--h682856c_1"

	input: 
		file "${reference.name}.sam" from bwa_mapped

	output:
		file "${reference.name}.bam" into bwa_mapped_bam

	script:
	// Create variables to apply, or not, several parameters
    // Create a variable to use several cores on this step
    def sambambacoresArgument 	= (params.sambamba.cores != null && params.sambamba.cores != 1)
        ? "-t ${params.sambamba.cores}" : ''

	"""
	sambamba view \
            ${sambambacoresArgument} \
    -S      ${reference.name}.sam \
    -o      ${reference.name}.bam \
    -f      bam
	"""
}

process bamSorting {
	tag "Bam Sorting"
	container "quay.io/biocontainers/sambamba:0.6.8--h682856c_1"

	input: 
		file "${reference.name}.bam"            from bwa_mapped_bam

	output:
		file "${reference.name}.sorted.bam" 	into bwa_sorted
		file "${reference.name}.sorted.bam.bai" into bwa_sorted_bai

	script:
		// Create a variable to choose a memory hint limit
		def sambambamemorylevelhint 	= (params.sambamba.memorylevelhint != null && params.sambamba.memorylevelhint != "")
			? "-m ${params.sambamba.memorylevelhint}" : ''

		// Create a variable to choose a compression level
		def sambambaCompressionArgument 	= (params.sambamba.compressionlevel != null && params.sambamba.compressionlevel != "")
			? "-l ${params.sambamba.compressionlevel}" : ''

	"""
	sambamba sort \
    ${sambambamemorylevelhint} \
    ${sambambaCompressionArgument} \
    ${reference.name}.bam \
        > ${reference.name}.sorted.bam 
	"""
}

def getPICARDoldCMD(arguments) 
{
	StringBuilder strb = new StringBuilder();
	for (key in arguments) 
	{
		strb.append(" ")
		strb.append(key.key)
		strb.append("=")
		strb.append(key.value)
	}
	return strb.toString()
}

def getPICARDnewCMD(arguments) 
{
	StringBuilder strb = new StringBuilder();
	for (key in arguments) 
	{
		strb.append(" -")
		strb.append(key.key)
		strb.append(" ")
		strb.append(key.value)
	}
	return strb.toString()
}

process removeDuplicates {
    tag "Remove Duplicates"
    container "quay.io/biocontainers/picard:2.18.25--0"

	input: 
		file "${reference.name}.sorted.bam" 	from bwa_sorted
		file "${reference.name}.sorted.bam.bai" from bwa_sorted_bai

	output:
		file "${reference.name}.sorted.noDuplicates.bam" 		into bwa_noduplicates
		file "${reference.name}.sorted.duplicates.metrics.txt" 	into bwa_noduplicates_metrics

	script:
        // As picard has two ways of passing arguments,
        //      we put then on a dictionary to latter 
        //      convert it to a CMD call line
		def arguments = [
			"I":                            "${reference.name}.sorted.bam",
			"O":                            "${reference.name}.sorted.noDuplicates.bam",
			"M":                            "${reference.name}.sorted.duplicates.metrics.txt",
			"TAG_DUPLICATE_SET_MEMBERS":    "true",
			"REMOVE_SEQUENCING_DUPLICATES": "true"
		]

		def picardCMD = getPICARDoldCMD(arguments)
		// def picardCMD = getPICARDnewCMD(arguments)

	"""
	picard MarkDuplicates ${picardCMD}
	"""
}

process decompress_reference {
    tag "Decompress reference for GATK"
    container "alpine:3.9"
    
	input:
	    file reference 

	output:
	    file "${reference.baseName}" into decompressed_reference

	"""
	gunzip -c ${reference} > ${reference.baseName}
	"""
}

process fastaIndex {
    tag "Index Reference Genome"
    container "quay.io/biocontainers/samtools:1.3.1--5"
    input:
  	    file "${reference.baseName}"        from decompressed_reference
  
    output:
        file "${reference.baseName}.fai"    into reference_index
  
    """
    samtools faidx ${reference.baseName}
    """
}

process referenceIndexDictionary {
    tag "Create reference dictionary"
    container "quay.io/biocontainers/picard:2.18.25--0"
    input:
  	    file "${reference.baseName}"                from decompressed_reference
  
    output:
  	    file "${reference.getBaseName(2)}.dict"     into reference_dict
  
    """
    picard CreateSequenceDictionary REFERENCE=${reference.baseName} OUTPUT=${reference.getBaseName(2)}.dict
    """
}

process noDuplicatesBAMindex {
    tag "Index No-Duplicates BAM"
    container "quay.io/biocontainers/samtools:1.3.1--5"
    input:
  	    file "${reference.name}.sorted.noDuplicates.bam"        from bwa_noduplicates
  
    output:
        file "${reference.name}.sorted.noDuplicates.bam.bai"    into bwa_noduplicates_bai
  
    """
    samtools index ${reference.name}.sorted.noDuplicates.bam
    """
}

// dbsnp = file(params.GATK.bundle + "hg19/dbsnp_135.hg19.no.chr.vcf.gz")
// dbsnp = file("/home/vfernandez/git/Wetlab2Variations/test/dbsnp_138.b37.vcf")

// mills1000Gindels = file(params.GATK.bundle + "Mills_and_1000G_gold_standard.indels.hg19.no.chr.vcf")
// mills1000Gindels = file("/home/vfernandez/git/Wetlab2Variations/test/Mills_and_1000G_gold_standard.indels.b37.vcf")

process baseQualityRecalibration {
	tag "Base quality recalibration (BQSR)"
	container "broadinstitute/gatk3:3.6-0"

	input: 
		file "${reference.baseName}"                            from decompressed_reference
		file "${reference.name}.sorted.noDuplicates.bam"        from bwa_noduplicates
		file "${reference.name}.sorted.noDuplicates.bam.bai"    from bwa_noduplicates_bai
		
		file "*" from knownSitesCh.collect()
		file "${reference.baseName}.fai"                        from reference_index
		file "${reference.getBaseName(2)}.dict"                 from reference_dict

	output:
        file "${reference.name}.sorted.noDuplicates.recalibrated.grp" into bwa_grp

    script:
        def knownSitesArgBuilder = new StringBuilder()

        for (vcf in params.BSQR.files)
        {
            knownSitesArgBuilder.append("--knownSites ")
            knownSitesArgBuilder.append(vcf)
            knownSitesArgBuilder.append(" ")
        }

        def knownSitesArg = knownSitesArgBuilder.toString()

	"""	
	java -jar /usr/GenomeAnalysisTK.jar \
	-T 				BaseRecalibrator \
	-nct 			8 \
	-R 				${reference.baseName} \
	--input_file 	${reference.name}.sorted.noDuplicates.bam \
	-dt 			NONE \
    -o  			${reference.name}.sorted.noDuplicates.recalibrated.grp \
                    ${knownSitesArg}
	"""

}

process printReads {
    container "broadinstitute/gatk3:3.6-0"
    input:
        file "${reference.baseName}"                                    from decompressed_reference
        file "${reference.name}.sorted.noDuplicates.bam"                from bwa_noduplicates
        file "${reference.name}.sorted.noDuplicates.recalibrated.grp"   from bwa_grp
        file "${reference.name}.sorted.noDuplicates.bam.bai"            from bwa_noduplicates_bai

        file "${reference.baseName}.fai"                                from reference_index
        file "${reference.getBaseName(2)}.dict"                         from reference_dict
  
    output:
        file "${reference.name}.sorted.noDuplicates.recalibrated.printed.bam" into bwa_printed
  
    """
    java -jar /usr/GenomeAnalysisTK.jar \
    -T      PrintReads \
    -R      ${reference.baseName} \
    -I      ${reference.name}.sorted.noDuplicates.bam \
    -BQSR   ${reference.name}.sorted.noDuplicates.recalibrated.grp \
    -o      ${reference.name}.sorted.noDuplicates.recalibrated.printed.bam
    """
}

process variantCalling {
  container "broadinstitute/gatk3:3.6-0"
  input:
    file "${reference.name}.sorted.noDuplicates.recalibrated.printed.bam"   from bwa_printed
    file "${reference.baseName}"                                            from decompressed_reference
    file "${reference.baseName}.fai"                                        from reference_index
    file "${reference.getBaseName(2)}.dict"                                 from reference_dict
  
  output:
    file "${reference.baseName}.sorted.noDuplicates.recalibrated.g.vcf.gz"      into gVCF
    file "${reference.baseName}.sorted.noDuplicates.recalibrated.g.vcf.gz.tbi"  into gTBI
  
  script:
    strBuilder = new StringBuilder()
    for (value in params.bwahaplotyper.gqb)
    {
        strBuilder.append("-GQB ")
        strBuilder.append("${value} ")
    }
    GQB = strBuilder.toString()
  
    """
    java -jar /usr/GenomeAnalysisTK.jar \
    -T                                  HaplotypeCaller \
    --num_cpu_threads_per_data_thread   ${params.bwahaplotyper.cputhreads} \
    -I                                  ${reference.name}.sorted.noDuplicates.recalibrated.printed.bam \
    -R                                  ${reference.baseName} \
    --min_base_quality_score            ${params.bwahaplotyper.minquality} \
    -ERC                                ${params.bwahaplotyper.erc} \
    -variant_index_type                 ${params.bwahaplotyper.variantindextype} \
    --variant_index_parameter           ${params.bwahaplotyper.variantindexparam} \
    -o                                  ${reference.baseName}.sorted.noDuplicates.recalibrated.g.vcf.gz \
                                        ${GQB}
    """

  //   -standard_call_conf 30 \
  //   -standard_emit_conf 10 \
   
}
