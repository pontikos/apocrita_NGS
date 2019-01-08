#!/bin/sh 

set -x

BASEDIR=/data2/Blizard-BoneMarrowFailure/

input=$1
# input is either a file or a string
if [ -f "${input}" ]
then
   echo input is file
   for code in `cat $input`
   do
     f1=`find ${BASEDIR}/fastq/exomes/ -name ${code}_R1_*.f*q.gz`
     outdir=`dirname $f1 | sed 's/fastq/bam\/b37/'`/${code}
     if [ ! -f ${outdir}/${code}_sorted_unique.bam.bai ]
     then
       zcat ${f1} | split -d -l 60000000 - ${f1}.part-
       zcat ${f2} | split -d -l 60000000 - ${f2}.part-
       for x in `ls -1 ${f1}.part-* | xargs -I {} basename {} \; | cut -f2 -d-`
       do
          echo qsub $BASEDIR/scripts/exomes/novoalign.sh $code $x
          qsub $BASEDIR/scripts/exomes/novoalign.sh $code $x
        done
     fi
     done
else
     echo input is a string
     code=$input
     f1=`find ${BASEDIR}/fastq/exomes/ -name ${code}_R1_*.f*q.gz`
     f2=`find ${BASEDIR}/fastq/exomes/ -name ${code}_R2_*.f*q.gz`
     outdir=`dirname $f1 | sed 's/fastq/bam\/b37/'`/${code}
     if [ ! -f ${outdir}/${code}_sorted_unique.bam.bai ]
     then
       zcat ${f1} | split -d -l 60000000 - ${f1}.part-
       zcat ${f2} | split -d -l 60000000 - ${f2}.part-
       for x in `ls -1 ${f1}.part-* | xargs -I {} basename {} \; | cut -f2 -d- `
       do
         echo qsub $BASEDIR/scripts/exomes/novoalign.sh $code $x
         qsub $BASEDIR/scripts/exomes/novoalign.sh $code $x
       done
      fi
fi

