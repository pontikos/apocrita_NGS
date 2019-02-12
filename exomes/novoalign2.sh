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
f1=$2
f2=$3

novoalignRef=${BASEDIR}Genome_and_jars/human_g1k_v37.fasta.k15.s2.novoindex
outdir=`dirname $f1 | sed 's/fastq/bam\/b37/'`/${code}

mkdir -p ${outdir}

novoalign -c ${ncores} -o SAM "@RG\tID:${code}\tSM:${code}\tLB:${code}\tPL:ILLUMINA" --rOQ --hdrhd 3 -H -k -a -o Soft -t 320 -F STDFQ -f ${f1} ${f2} -d ${novoalignRef} | samblaster -e -d ${outdir}/${code}_disc.sam  | samtools view --threads ${ncores} -Sb - > ${outdir}/${code}.bam
samtools view --threads ${ncores} -Sb ${outdir}/${code}_disc.sam > ${outdir}/${code}_disc.bam
rm ${outdir}/${code}_disc.sam

