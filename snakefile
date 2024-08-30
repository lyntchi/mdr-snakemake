#Sankefile for variant calling for MDR  from iontorrent.
#Define the input fastq files
SAMPLES = ["MDR01","MDR07","MDR08"]

rule all:
     input:
       expand("result/{sample}_sorted.bam",sample=SAMPLES),
       expand("result/{sample}_sorted.bam.bai",sample=SAMPLES),
       expand("result/{sample}_trimmed.fastq",sample=SAMPLES),
       expand("result/{sample}_fastqc.html",sample=SAMPLES),
       expand("result/{sample}_fastqc.zip",sample=SAMPLES)
 
#Step 1:# Quality control using FastQC
rule qc:
      input:
          "data/{sample}.fastq"
      output:
          "result/{sample}_fastqc.html",
          "result/{sample}_fastqc.zip"
      shell:
          """
          fastqc {input} -o result/
          """
 
  # Step 2: Quality Trimming with Trimmomatic
  rule trim_reads:
      input:
          "data/{sample}.fastq"
      output:
          "result/{sample}_trimmed.fastq"
      log:
          "logs/{sample}_trimmomatic.log"
      shell:
          """
          trimmomatic SE -phred33 {input} {output} \
          SLIDINGWINDOW:4:20 MINLEN:50 > {log} 2>&1
          """
 # Step 3: Align reads to reference genome using BWA, and index BAM files
  rule align_and_index:
      input:
          fastq="result/{sample}_trimmed.fastq",
          reference="references/uploaded_reference.fasta"
      output:
        sorted_bam="result/{sample}_sorted.bam",
         sorted_bai="result/{sample}_sorted.bam.bai"
     shell:
          """
         bwa mem {input.reference} {input.fastq} \
          | samtools sort -o {output.sorted_bam} \
          && samtools index {output.sorted_bam}
            """

