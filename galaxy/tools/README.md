
# Readme

This is a short docmunetation on the steps to take to use the workflow.

The content is briefly divided in:

- configure your galaxy instance to use containers
- copy the tool files
- configure the remainig tools to use a container

As a convention in this document the Galaxy installation directory is called `$GALAXY_ROOT`.

During the manual installation of th etools you will be required ot restart Galaxy, be prepared for it.

## 1. Configure your Galaxy instance

During the project was used Galaxy version 19.01, if you are planning to use a more recente  version of Galaxy you should compare the docs for possible changes of configuratons and best practices.
As container manager/runtims the choice fall on Docker, if you plan to use anothe one you need to see to difference in configurations yourself.

From the [official docs](https://docs.galaxyproject.org/en/release_19.01/admin/special_topics/mulled_containers.html)

>Since 2014 Galaxy supports running tools in Docker containers via a special container annotation inside of the requirement field.

An example is provided [here](https://github.com/galaxyproject/galaxy/blob/dev/test/functional/tools/catDocker.xml#L4).

But that is not all, you also need to install docker and make it executable by Galaxy.
The Docker installation is system specific and I advise to serch either the package mamager of your distro or the official docker [documentation/website](https://docs.docker.com/install/).

Once the Docker daemon is up and running, you need to make gaalxy be able to run docker commands. there are many recipies on the Internet with vaious degree of compromise between security and ease of use.
In this project Galaxy runs in a Virtual Machine in a trusted environment not directly exposed to the internet, so the easy solution was to add the sudoers file these two lines:

```config
# allow the galaxy user to run docker without password
galaxy  ALL = (root) NOPASSWD: SETENV: /usr/bin/docker
```

Assuming your Galaxy instance is running and normal unpriviledge user named `galaxy` this should allow it to run `docker` commands without a password, but it still need to sudo the command.

Nesxt step is to configure the job runner to use `docker`, the configuration file to do so is in `$GALAXY_ROOT/config/job_conf.xml`. An example configurations is:

```xml
<?xml version="1.0"?>
<job_conf>
    <plugins>
        <plugin id="local" type="runner" load="galaxy.jobs.runners.local:LocalJobRunner" workers="4"/>
    </plugins>
    <destinations default="docker_local">
        <destination id="local" runner="local"/>s
        <destination id="docker_local" runner="local">
                <param id="docker_enabled">true</param>
                <param id="docker_sudo">true</param>
                <param id="docker_volumes">$defaults,/mnt/galaxyData/libraries:ro,/mnt/galaxyData/indices:ro,/cvmfs/data.galaxyproject.org:ro</param>
        </destination>
    </destinations>
</job_conf>
```

## 2. Copy the tool files

The workflow is a proof-of-concept, so right now is not entirely avilabe from the official Galaxy tool sheds, also because of licensing issue of GATK v3.
Under the tools directory you can find the tools not distributes through official channels and that need to be installed by hand.
The procedure is documented [here](https://galaxyproject.org/admin/tools/add-tool-tutorial/).
It is advisable to keep the manually installed toosl separated from the oters and to create a tool panel section in Galaxy. to do this you need to create a new directory under `$GALAXY_ROOT/config/tools/` e.g. `$GALAXY_ROOT/config/tools/Wetlab2Variations`.
Copy there the files you can find under the tools directory.
Modify your  `$GALAXY_ROOT/config/tools_config.xml` file to make Galaxy aware of the new tools by adding a section element containig a tool element for each new tool, e.g.

```xml
 <section id="wetlab2variations" name="Wetlab2Variations">
    <tool file="Wetlab2Variations/picard-CreateSequenceDictionary.xml" />
    <tool file="Wetlab2Variations/picard-MarkDuplicates.xml" />
    <tool file="Wetlab2Variations/gatk-IndelRealigner.xml" />
    <tool file="Wetlab2Variations/gatk-BaseRecalibrator.xml" />
    <tool file="Wetlab2Variations/gatk-PrintReads.xml" />
    <tool file="Wetlab2Variations/gatk-HaplotypeCaller.xml" />
    <tool file="Wetlab2Variations/gatk-RealignerTargetCreator.xml" />
</section>
```

Once everyting is done you need to restart Galaxy to make the changes available.

## 3. Configure the remainig tools to use a container

The rest of the tools composing the workflow are available from the official tool shed.
Assuming you actually installed them through the official toolshed you can find the tools files under `$GALAXY_ROOT/database/shed_tools/toolshed.g2.bx.psu.edu/repos/` once there you need to find out under which repository name they are, e.g. devteam or iuc or another one, and which commit hash.

For example in my installation BWA tool files can be found under `$GALAXY_ROOT/database/shed_tools/toolshed.g2.bx.psu.edu/repos/devteam/bwa/8d2a528a9513/bwa`

```console
galaxy@host:~$ ls -l $GALAXY_ROOT/database/shed_tools/toolshed.g2.bx.psu.edu/repos/devteam/bwa/8d2a528a9513/bwa
total 80
-rw-r--r-- 1 galaxy galaxy   100 May 31 08:52 README.rst
-rw-r--r-- 1 galaxy galaxy 21982 May 31 08:52 bwa-mem.xml
-rw-r--r-- 1 galaxy galaxy 19159 May 31 08:52 bwa.xml
-rw-r--r-- 1 galaxy galaxy 10265 Jun  5 10:35 bwa_macros.xml
-rw-r--r-- 1 galaxy galaxy 11275 May 31 08:52 read_group_macros.xml
drwxr-xr-x 2 galaxy galaxy  4096 May 31 08:52 test-data
drwxr-xr-x 2 galaxy galaxy    37 May 31 08:52 tool-data
-rw-r--r-- 1 galaxy galaxy   446 May 31 08:52 tool_data_table_conf.xml.sample
```

To stick with teh BWA exmaple we then need to edit the `bwa_macros.xml` file and look for the macro xml elemnt named`requirement`, once found we need to add the requirememnt to use the BioContainer image of the tools. Tools plural because in the case of BWA there are two tools, BWA for the alignment and samtools to sort the SAM output and convert it to BAM.

So in the end the requirement element shooul look similar to this:

```xml
<xml name="requirements">
        <requireents>
            <requirement type="package" version="@VERSION@">bwa</requirement>
            <requirement type="package" version="1.6">samtools</requirement>
                <container type="docker">quay.io/biocontainers/mulled-v2-fe8faa35dbf6dc65a0f7f5d4ea12e31a79f73e40:23592e4ad15ca2acfca18facab87a1ce22c49da1-0</container>
        </requirements>
</xml>
```

Once all the tools in the workflow are configured properly you can import the workfow file and run it.
