#Sankefile for variant calling for MDR  from iontorrent.
  2 #Define the input fastq files
  3 SAMPLES = ["MDR01","MDR02","MDR03","MDR04","MDR05","MDR06","MDR07","MDR08"]
  4
  5 rule all:
  6     input
  8         expand("results/{sample}_sorted.bam.bai", sample=SAMPLES),
  9         expand("results/{sample}_sorted.bam", sample=SAMPLES),
 10         expand("results/{sample}_trimmed.fastq",sample=SAMPLES),
 11         expand("results/{sample}_fastqc.html",sample=SAMPLES),
 12         expand("results/{sample}_fastqc.zip",sample=SAMPLES)
 13
 14 #Step 1:# Quality control using FastQC
 15 rule qc:
 16     input:
 17         "data/{sample}.fastq"
 18     output:
 19         "results/{sample}_fastqc.html",
 20         "results/{sample}_fastqc.zip"
 21     shell:
 22         """
 23         fastqc {input} -o results/
 24         """
 25
 26 # Step 2: Quality Trimming with Trimmomatic
 27 rule trim_reads:
 28     input:
 29         "data/{sample}.fastq"
 30     output:
 31         "results/{sample}_trimmed.fastq"
 32     log:
 33         "logs/{sample}_trimmomatic.log"
 34     shell:
 35         """
 36         trimmomatic SE -phred33 {input} {output} \
 37         SLIDINGWINDOW:4:20 MINLEN:50 > {log} 2>&1
 38         """
 39
 40  # Step 3: Align reads to reference genome using BWA
 41 rule align_reads:
 42     input:
 43         "results/{sample}_trimmed.fastq",
 44         "reference/Plasmodium_falciparum_reference.fasta"
 45     output:
 46         "results/{sample}_sorted.bam"
 47     log:
 48         "logs/{sample}_bwa.log",
 49         "logs/{sample}_samtools.log"
 50     shell:
 51         """
 52         bwa mem {input[1]} {input[0]} | samtools sort -o {output}
 53         """
 54 #Step 4: Indexing bam files
 55 rule index_bam:
 56     input:
 57         "results/{sample}_sorted.bam"
 58     output:
 59         "results/{sample}_sorted.bam.bai"
 60     shell:
 61         """
 62         samtools index {input}
 63         """
