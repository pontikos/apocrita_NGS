#!/bin/sh 
#$ -cwd
#$ -pe smp 40
#$ -l h_rt=1:00:00
#$ -l h_vmem=2G  

set -x

ncores=40
memory2=2
memory=$(printf %.0f $(echo "$ncores * $memory2" | bc -l))

code=$1
BASEDIR=/data2/Blizard-BoneMarrowFailure/

in_bam=`find ${BASEDIR}/bam/b37/exomes/ -name ${code}_sorted_unique.bam`
outdir=`dirname $in_bam | sed 's/bam/vcf/'`/
mkdir -p $outdir
out_gvcf=${outdir}/${code}.g.vcf.gz


# GATK=${Software}/GenomeAnalysisTK-3.4-46/GenomeAnalysisTK.jar
GATK=${BASEDIR}/Genome_and_jars/GenomeAnalysisTK-3.5-0/GenomeAnalysisTK.jar
# java -Djava.io.tmpdir=${tempFolder} -Xmx4g -jar ${GATK}
# CombineGVCFs="$java -Djava.io.tmpdir=/scratch0/ -Xmx4g -Xms4g -jar $GATK -T CombineGVCFs"
fasta=/data/home/hmw222/Blizard-BoneMarrowFailure/Genome_and_jars/human_g1k_v37.fasta

java -Xmx${memory}g -Xms${memory}g -jar $GATK -T HaplotypeCaller -nct $ncores -R ${fasta} -I ${in_bam}  --emitRefConfidence GVCF -rf NotPrimaryAlignment -stand_call_conf 30.0 -stand_emit_conf 10.0 --GVCFGQBands 10 --GVCFGQBands 20 --GVCFGQBands 50 -o ${out_gvcf} 


