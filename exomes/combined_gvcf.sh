#!/bin/sh 
#$ -cwd
#$ -pe smp 40
#$ -l h_rt=1:00:00
#$ -l h_vmem=2G
#$ -t 1-23

array=( dud `seq 1 22` X )
CHROM=${array[ $SGE_TASK_ID ]}

set -x

ncores=40
memory2=2
memory=$(printf %.0f $(echo "$ncores * $memory2" | bc -l))

echo $memory

batchname=$1
BASEDIR=/data2/Blizard-BoneMarrowFailure/

output=chr${CHROM}_${batchname}.vcf.gz

# GATK=${Software}/GenomeAnalysisTK-3.4-46/GenomeAnalysisTK.jar
GATK=${BASEDIR}/Genome_and_jars/GenomeAnalysisTK-3.5-0/GenomeAnalysisTK.jar
# java -Djava.io.tmpdir=${tempFolder} -Xmx4g -jar ${GATK}
# CombineGVCFs="$java -Djava.io.tmpdir=/scratch0/ -Xmx4g -Xms4g -jar $GATK -T CombineGVCFs"
fasta=/data/home/hmw222/Blizard-BoneMarrowFailure/Genome_and_jars/human_g1k_v37.fasta

#java -Xmx${memory}g -Xms${memory}g -jar $GATK -T HaplotypeCaller -nct $ncores -R ${fasta} -I ${in_bam}  --emitRefConfidence GVCF -rf NotPrimaryAlignment -stand_call_conf 30.0 -stand_emit_conf 10.0 --GVCFGQBands 10 --GVCFGQBands 20 --GVCFGQBands 50 -o ${out_gvcf} 

in_gvcf=`find ${BASEDIR}/vcf/b37/exomes/ -name "chr${CHROM}_*.g.vcf.gz" | xargs -I {} echo --variant {}`

java -Xmx${memory}g -Xms${memory}g -jar $GATK -T CombineGVCFs -R $fasta -L ${CHROM} -o ${output} ${in_gvcf}


