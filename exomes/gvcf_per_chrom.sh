#!/bin/sh 
#$ -cwd
#$ -pe smp 20
#$ -l h_rt=1:00:00
#$ -l h_vmem=4G
#$ -t 1-23

array=( dud `seq 1 22` X )
CHROM=${array[ $SGE_TASK_ID ]}

set -x

ncores=$NSLOTS
memory2=2

code=$1
BASEDIR=/data2/Blizard-BoneMarrowFailure/

in_bam=`find ${BASEDIR}/bam/b37/exomes/ -name ${code}_sorted_unique.bam`
outdir=`dirname $in_bam | sed 's/bam/vcf/'`/
mkdir -p $outdir

# GATK=${Software}/GenomeAnalysisTK-3.4-46/GenomeAnalysisTK.jar
GATK=${BASEDIR}/Genome_and_jars/GenomeAnalysisTK-3.5-0/GenomeAnalysisTK.jar
# java -Djava.io.tmpdir=${tempFolder} -Xmx4g -jar ${GATK}
# CombineGVCFs="$java -Djava.io.tmpdir=/scratch0/ -Xmx4g -Xms4g -jar $GATK -T CombineGVCFs"
fasta=/data/home/hmw222/Blizard-BoneMarrowFailure/Genome_and_jars/human_g1k_v37.fasta

java -Xmx48g -Xms48g -jar $GATK -T HaplotypeCaller -nct $ncores -R ${fasta} -I ${in_bam}  --emitRefConfidence GVCF -rf NotPrimaryAlignment -stand_call_conf 30.0 -stand_emit_conf 10.0 --GVCFGQBands 10 --GVCFGQBands 20 --GVCFGQBands 50 -o ${outdir}/chr${CHROM}_${code}.g.vcf.gz -L $CHROM
