#!/bin/sh 
#$ -cwd           # Set the working directory for the job to the current directory 
#$ -pe smp 2      
#$ -l h_rt=1:0:0 
#$ -l h_vmem=32G  

set -x

ncores=2

module load samtools 
module load bwa 

SAMPLE=$1 
GENOME_AND_JARS_DIR=/data2/Blizard-BoneMarrowFailure/Genome_and_jars/ 
REFERENCE=${GENOME_AND_JARS_DIR}/hg19.fa 
ANNOVAR_DIR=/data2/Blizard-BoneMarrowFailure/annovar/ 
FASTQ_DIR=/data2/Blizard-BoneMarrowFailure/fastq/gene_panel/
BAM_DIR=/data2/Blizard-BoneMarrowFailure/bam/b37/gene_panel/
VCF_DIR=/data2/Blizard-BoneMarrowFailure/vcf/b37/gene_panel/
CSV_DIR=/data2/Blizard-BoneMarrowFailure/csv/b37/gene_panel/


# alignment of genome
bwa mem -t $ncores $REFERENCE $FASTQ_DIR/*${SAMPLE}*_R1_*.fastq.gz $FASTQ_DIR/*${SAMPLE}*_R2_*.fastq.gz | samtools view -bS - > ${BAM_DIR}/${SAMPLE}.bam

# sort file
samtools sort --threads $ncores ${BAM_DIR}/${SAMPLE}.bam -o ${BAM_DIR}/${SAMPLE}.sorted.bam

samtools index ${BAM_DIR}/${SAMPLE}.sorted.bam 

java -jar ${GENOME_AND_JARS_DIR}/AddOrReplaceReadGroups.jar I=${BAM_DIR}/${SAMPLE}.sorted.bam O=${BAM_DIR}/${SAMPLE}.grouped.bam LB=identifier PL=ILLUMINA PU=000000000 SM=${SAMPLE}

java -jar ${GENOME_AND_JARS_DIR}/ReorderSam.jar I=${BAM_DIR}/${SAMPLE}.grouped.bam O=${BAM_DIR}/${SAMPLE}.kar.bam REFERENCE=${REFERENCE}

samtools index ${BAM_DIR}/${SAMPLE}.kar.bam

java -jar ${GENOME_AND_JARS_DIR}/GenomeAnalysisTK.jar -T HaplotypeCaller -R $REFERENCE -I ${BAM_DIR}/${SAMPLE}.kar.bam -stand_call_conf 30 -stand_emit_conf 10 -minPruning 3 -o ${VCF_DIR}/${SAMPLE}.raw.vcf.gz

perl $ANNOVAR_DIR/convert2annovar.pl -format vcf4 ${VCF_DIR}/${SAMPLE}.raw.vcf.gz -includeinfo > ${CSV_DIR}/${SAMPLE}.avinput

perl $ANNOVAR_DIR/table_annovar.pl ${CSV_DIR}/${SAMPLE}.avinput $ANNOVAR_DIR/humandb/ -buildver hg19 --otherinfo -out ${CSV_DIR}/${SAMPLE} -remove -protocol refGene,cytoBand,genomicSuperDups,esp6500si_all,1000g2012apr_all,snp138,ljb23_pp2hvar,ljb23_sift,exac03 -operation g,r,r,f,f,f,f,f,f -nastring . -csvout 



