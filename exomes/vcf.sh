#!/bin/sh 
#$ -cwd
#$ -pe smp 32
#$ -l h_rt=1:0:0 
#$ -l h_vmem=1.5G  
#$ -t 1-23

cleanChr=(targets 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 X Y )
CHROM=\${cleanChr[ \$SGE_TASK_ID ]}

set -x

ncores=32
memory2=1.5

code=$1
BASEDIR=/data2/Blizard-BoneMarrowFailure/

in_bam=`find ${BASEDIR}/bam/b37/exomes/ -name ${code}_sorted_unique.bam`
outdir=`dirname $in_bam | sed 's/bam/vcf/'`/
mkdir -p $outdir
out_vcf=${outdir}/${code}.vcf.gz


# GATK=${Software}/GenomeAnalysisTK-3.4-46/GenomeAnalysisTK.jar
GATK=${BASEDIR}/Genome_and_jars/GenomeAnalysisTK-3.5-0/GenomeAnalysisTK.jar
# java -Djava.io.tmpdir=${tempFolder} -Xmx4g -jar ${GATK}
# CombineGVCFs="$java -Djava.io.tmpdir=/scratch0/ -Xmx4g -Xms4g -jar $GATK -T CombineGVCFs"
fasta=/data/home/hmw222/Blizard-BoneMarrowFailure/Genome_and_jars/human_g1k_v37.fasta

java -Xmx48g -Xms48g -jar $GATK -T HaplotypeCaller -nct $ncores -R ${fasta} -I ${in_bam} -o ${out_vcf} -L ${cleanChr}


