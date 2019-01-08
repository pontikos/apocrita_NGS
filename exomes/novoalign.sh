#!/bin/sh 
#$ -cwd 
#$ -pe smp 40
#$ -l h_rt=1:00:00
#$ -l h_vmem=2G  

set -x

ncores=40
memory2=2

BASEDIR=/data2/Blizard-BoneMarrowFailure/

code=$1
x=$2
if [[ -z "${x}" ]]
then
    f1=`find ${BASEDIR}/fastq/exomes/ -name ${code}_R1_*.f*q.gz`
    f2=`find ${BASEDIR}/fastq/exomes/ -name ${code}_R2_*.f*q.gz`
    novoalignRef=${BASEDIR}Genome_and_jars/human_g1k_v37.fasta.k15.s2.novoindex
    outdir=`dirname $f1 | sed 's/fastq/bam\/b37/'`/${code}
    mkdir -p ${outdir}
    novoalign -c ${ncores} -o SAM "@RG\tID:${code}\tSM:${code}\tLB:${code}\tPL:ILLUMINA" --rOQ --hdrhd 3 -H -k -a -o Soft -t 320 -F STDFQ -f ${f1} ${f2} -d ${novoalignRef} | samblaster -e -d ${outdir}/${code}_disc.sam  | samtools view --threads ${ncores} -Sb - > ${outdir}/${code}.bam
    samtools view --threads ${ncores} -Sb ${outdir}/${code}_disc.sam > ${outdir}/${code}_disc.bam
    rm ${outdir}/${code}_disc.sam
else
    f1=`find ${BASEDIR}/fastq/exomes/ -name ${code}_R1_*.f*q.gz`
    f2=`find ${BASEDIR}/fastq/exomes/ -name ${code}_R2_*.f*q.gz`
    novoalignRef=${BASEDIR}Genome_and_jars/human_g1k_v37.fasta.k15.s2.novoindex
    outdir=`dirname $f1 | sed 's/fastq/bam\/b37/'`/${code}
    mkdir -p ${outdir}
    novoalign -c ${ncores} -o SAM "@RG\tID:${code}\tSM:${code}\tLB:${code}\tPL:ILLUMINA" --rOQ --hdrhd 3 -H -k -a -o Soft -t 320 -F STDFQ -f ${f1}*-${x} ${f2}*-${x} -d ${novoalignRef} | samblaster -e -d ${outdir}/${code}_disc-${x}.sam  | samtools  view --threads ${ncores} -Sb - > ${outdir}/${code}-${x}.bam
    samtools view --threads ${ncores} -Sb ${outdir}/${code}_disc-${x}.sam > ${outdir}/${code}_disc-${x}.bam
    rm ${outdir}/${code}_disc-${x}.sam ${f1}*-${x} ${f2}*-${x}
fi

