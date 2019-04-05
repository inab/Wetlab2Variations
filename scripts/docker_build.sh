#!/usr/bin/env bash

# build cnag/cutadapt:1.18
docker build -t cnag/cutadapt:1.18 -f containers/cutadapt/cutadapt-Dockerfile .

# build cnag/bwa:0.7.17
docker build -t cnag/bwa:0.7.17 -f containers/bwa/bwa-Dockerfile .

# build cnag/picard:2.18.25
docker build -t cnag/picard:2.18.25 -f containers/picard/picard-Dockerfile .

# build cnag/gatk:3.6-0
docker build -t cnag/gatk:3.6-0 -f containers/gatk/gatk3-Dockerfile .

# build cnag/fastqc:0.11.8
docker build -t cnag/fastqc:0.11.8 -f containers/fastqc/fastqc-Dockerfile .

# build cnag/sambamba:0.6.8
docker build -t cnag/sambamba:0.6.8 -f containers/sambamba/sambamba-Dockerfile .