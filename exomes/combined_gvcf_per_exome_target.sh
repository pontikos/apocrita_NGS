#!/bin/sh 
#$ -cwd
#$ -l h_rt=1:00:00
#$ -l h_vmem=30G
#$ -t 1-721

args=(`find /data2/Blizard-BoneMarrowFailure/reference_genomes/exome_target/ -name '*.bed' | sort`)
target=${args[$SGE_TASK_ID]}

set -x

memory=30
echo $memory

batchname=$1
samples="$2"

BASEDIR=/data2/Blizard-BoneMarrowFailure/

echo $target

target_name=`basename ${target%.bed}`

echo $target_name

mkdir -p /data/home/hmw222/Blizard-BoneMarrowFailure/batches/${target_name}/
output=/data/home/hmw222/Blizard-BoneMarrowFailure/batches/${target_name}/${batchname}.gvcf.gz

# GATK=${Software}/GenomeAnalysisTK-3.4-46/GenomeAnalysisTK.jar
GATK=${BASEDIR}/Genome_and_jars/GenomeAnalysisTK-3.5-0/GenomeAnalysisTK.jar
# java -Djava.io.tmpdir=${tempFolder} -Xmx4g -jar ${GATK}
# CombineGVCFs="$java -Djava.io.tmpdir=/scratch0/ -Xmx4g -Xms4g -jar $GATK -T CombineGVCFs"
fasta=/data/home/hmw222/Blizard-BoneMarrowFailure/Genome_and_jars/human_g1k_v37.fasta

if [ -f "${samples}" ] && [ "${samples}"!="" ]
then
    echo samples files $samples
    for s in `cat $samples`
    do
        f=`find ${BASEDIR}/vcf/b37/exomes/ -name "${target_name}_${s}.g.vcf.gz"`
        if [ "${f}" == "" ]
        then
            f=`find ${BASEDIR}/vcf/b37/exomes/ -name "${s}_${target_name}.g.vcf.gz"`
        fi
        if [ "${f}" == "" ]
        then
            echo "could not find ${target_name}_${s}.g.vcf.gz"
            exit 1
        else
            in_gvcf="${in_gvcf} --variant ${f}"
        fi
    done
else
    echo no samples file $samples
    in_gvcf=`find ${BASEDIR}/vcf/b37/exomes/ -name "${target_name}_${batchname}_*.g.vcf.gz" | xargs -I {} echo --variant {}`
    if [ "${in_gvcf}" == "" ]
    then
        in_gvcf=`find ${BASEDIR}/vcf/b37/exomes/ -name "${batchname}_*_${target_name}.g.vcf.gz" | xargs -I {} echo --variant {}`
    fi
fi

java -Xmx${memory}g -Xms${memory}g -jar $GATK -T CombineGVCFs -R $fasta -L ${target} -o ${output} ${in_gvcf}


