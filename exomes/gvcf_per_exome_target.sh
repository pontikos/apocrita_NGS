#!/bin/sh 
#$ -cwd
#$ -pe smp 20
#$ -l h_rt=1:00:00
#$ -l h_vmem=3G
#$ -t 1-721

args=(`find /data2/Blizard-BoneMarrowFailure/reference_genomes/exome_target/ -name '*.bed' | sort`)
target=${args[$SGE_TASK_ID]}

echo $target

set -x

ncores=$NSLOTS
memory=`expr 2 "*" $NSLOTS`

target_name=`basename ${target%.bed}`

echo $target_name

code=$1
BASEDIR=/data2/Blizard-BoneMarrowFailure/

in_bam=`find ${BASEDIR}/bam/b37/exomes/ -name ${code}_sorted_unique.bam`
outdir=`dirname $in_bam | sed 's/bam/vcf/'`/
mkdir -p $outdir

# GATK=${Software}/GenomeAnalysisTK-3.4-46/GenomeAnalysisTK.jar
GATK=${BASEDIR}/Genome_and_jars/GenomeAnalysisTK-3.5-0/GenomeAnalysisTK.jar
fasta=/data/home/hmw222/Blizard-BoneMarrowFailure/Genome_and_jars/human_g1k_v37.fasta

if [ -f ${outdir}/${target_name}_${code}.g.vcf.gz.tbi ]
then
    echo ${outdir}/${target_name}_${code}.g.vcf.gz.tbi exists
else
    java -Xmx${memory}g -Xms${memory}g -jar $GATK -T HaplotypeCaller -nct $ncores -R ${fasta} -I ${in_bam}  --emitRefConfidence GVCF -rf NotPrimaryAlignment -stand_call_conf 30.0 -stand_emit_conf 10.0 --GVCFGQBands 10 --GVCFGQBands 20 --GVCFGQBands 50 -o ${outdir}/${target_name}_${code}.g.vcf.gz -L ${target}
fi

