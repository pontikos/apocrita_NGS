#!/bin/sh 
#$ -cwd           # Set the working directory for the job to the current directory 
#$ -pe smp 36
#$ -l h_rt=1:0:0 
#$ -l h_vmem=5G  

set -x

ncores=36
memory2=5

BASEDIR=/data2/Blizard-BoneMarrowFailure/

input=$1


# is it a file?
if [ -f $input ]
then
    for code in `cat $input`
    do
        f1=`find ${BASEDIR}/fastq/exomes/ -name ${code}_R1_*.f*q.gz`
        outdir=`dirname $f1 | sed 's/fastq/bam\/b37/'`/${code}
        if [ ! -f ${outdir}/${code}_sorted_unique.bam.bai ]
        then
            qsub $BASEDIR/scripts/exomes/novosort.sh $code
        fi
    done
else
    code=$input
    in_bam=`find ${BASEDIR}/bam/b37/exomes/ -name "${code}-*.bam"`
    outdir=`dirname $in_bam | head -n1`
    out_sorted_bam=${outdir}/${code}_sorted_unique.bam
    in_disc_bam=`find ${BASEDIR}/bam/b37/exomes/ -name "${code}_disc-*.bam"`
    out_disc_sorted_bam=${outdir}/${code}_disc_sorted.bam
    # SAMBLASTER: fast duplicate marking and structural variant read extraction
    novosort -t ${outdir} -c ${ncores} -m ${memory2}G -i -o ${out_disc_sorted_bam} ${in_disc_bam} 
    # sort
    novosort -t ${outdir} -c ${ncores} -m ${memory2}G -i -o ${out_sorted_bam} ${in_bam}
    rm ${in_bam}
    rm ${in_disc_bam}
fi



