#!/bin/sh 

# full pass of directry (pod5)
export DIR1=$1
# full pass of working directry
export DIR2=$2

export CURDIR=`pwd`

cd ${DIR2}/

/home/minit/nanopore/software/dorado-0.6.1-linux-x64/bin/dorado download --model dna_r10.4.1_e8.2_400bps_sup@v4.3.0 --directory ${DIR2}

/home/minit/nanopore/software/dorado-0.6.1-linux-x64/bin/dorado basecaller dna_r10.4.1_e8.2_400bps_sup@v4.3.0 ${DIR1} > ${DIR2}/test.bam
/home/minit/nanopore/software/dorado-0.6.1-linux-x64/bin/dorado demux --kit-name SQK-NBD114-24 -o ${DIR2}/out ${DIR2}/test.bam
#/home/minit/nanopore/software/dorado-0.6.1-linux-x64/bin/dorado demux --kit-name SQK-NBD114-96 -o ${DIR2}/out ${DIR2}/test.bam
mv ${DIR2}/out/* ${DIR2}/
rmdir ${DIR2}/out
rm -f ${DIR2}/test.bam
rm -f ${DIR2}/unclassified.bam
for v in `seq 1 24`
#for v in `seq 1 96`
  do
  var=$(printf "%02d" $v)

  if [ -f ${DIR2}/SQK-NBD114-24_barcode${var}.bam ]; then
#  if [ -f ${DIR2}/SQK-NBD114-96_barcode${var}.bam ]; then

    mv ${DIR2}/SQK-NBD114-24_barcode${var}.bam ${DIR2}/out_simplex.barcode${var}.bam
#    mv ${DIR2}/SQK-NBD114-96_barcode${var}.bam ${DIR2}/out_simplex.barcode${var}.bam

    /usr/local/bin/samtools fastq ${DIR2}/out_simplex.barcode${var}.bam > ${DIR2}/out_simplex.barcode${var}.all.fastq

    export BASENAME="${DIR2}/out_simplex.barcode${var}"
    echo ${BASENAME}

    export THREAD=2
    export MINLEN=8300
    export MAXLEN=9800
    export LEN=8800
    NanoFilt -l ${MINLEN} --maxlength ${MAXLEN} ${BASENAME}.all.fastq > ${BASENAME}.trim.fastq

  fi
done

/home/minit/nanopore/software/dorado-0.6.1-linux-x64/bin/dorado duplex --min-qscore 10 dna_r10.4.1_e8.2_400bps_sup@v4.3.0 ${DIR1} > ${DIR2}/test.bam
/home/minit/nanopore/software/dorado-0.6.1-linux-x64/bin/dorado demux --kit-name SQK-NBD114-24 -o ${DIR2}/out ${DIR2}/test.bam
#/home/minit/nanopore/software/dorado-0.6.1-linux-x64/bin/dorado demux --kit-name SQK-NBD114-96 -o ${DIR2}/out ${DIR2}/test.bam
mv ${DIR2}/out/* ${DIR2}/
rmdir ${DIR2}/out
rm -f ${DIR2}/test.bam
rm -f ${DIR2}/unclassified.bam
for v in `seq 1 24`
#for v in `seq 1 96`
  do
  var=$(printf "%02d" $v)

  if [ -f ${DIR2}/SQK-NBD114-24_barcode${var}.bam ]; then
#  if [ -f ${DIR2}/SQK-NBD114-96_barcode${var}.bam ]; then

    mv ${DIR2}/SQK-NBD114-24_barcode${var}.bam ${DIR2}/out_duplex.q10.barcode${var}.bam
#    mv ${DIR2}/SQK-NBD114-96_barcode${var}.bam ${DIR2}/out_duplex.q10.barcode${var}.bam

    /usr/local/bin/samtools view ${DIR2}/out_duplex.q10.barcode${var}.bam | grep "[[:space:]]dx:i:1" > ${DIR2}/out_duplex.q10.barcode${var}.sam
    /usr/local/bin/samtools fastq ${DIR2}/out_duplex.q10.barcode${var}.sam > ${DIR2}/out_duplex.q10.barcode${var}.all.fastq
    
    export BASENAME="${DIR2}/out_duplex.q10.barcode${var}"
    echo ${BASENAME}

    export THREAD=2
    export MINLEN=8300
    export MAXLEN=9800
    export LEN=8800
    NanoFilt -l ${MINLEN} --maxlength ${MAXLEN} ${BASENAME}.all.fastq > ${BASENAME}.trim.fastq

    minimap2 -a -x map-ont -A 2 -O 24,24 -E 2,2 --secondary=no /home/minit/nanopore/tools/HXB2.790-9719.fas  ${BASENAME}.trim.fastq > ${BASENAME}.trim.tmp.sam

    /home/minit/nanopore/tools/check-sam.pl ${BASENAME}.trim.tmp.sam > ${BASENAME}.trim.tmp.c.sam 

    /home/minit/nanopore/tools/sam2alignment.pl ${BASENAME}.trim.tmp.c.sam /home/minit/nanopore/tools/HXB2.790-9719.fas | /home/minit/nanopore/tools/HomoPoly-check.pl > ${BASENAME}.trim.c.align.tmp.fas

    /home/minit/nanopore/tools/make-consensus.ref.pl ${BASENAME}.trim.c.align.tmp.fas > ${BASENAME}.ref.fas
    minimap2 -a -x map-ont -A 2 -O 24,24 -E 2,2 --secondary=no ${BASENAME}.ref.fas  ${BASENAME}.trim.fastq > ${BASENAME}.trim.sam
    /home/minit/nanopore/tools/check-sam.pl ${BASENAME}.trim.sam > ${BASENAME}.trim.c.sam 

    /home/minit/nanopore/tools/sam2alignment.pl ${BASENAME}.trim.c.sam /home/minit/nanopore/tools/HXB2.790-9417.fas | /home/minit/nanopore/tools/HomoPoly-check.pl > ${BASENAME}.trim.c.align.fas
    /home/minit/nanopore/tools/extract-gene.aa.all.sh ${BASENAME}.trim.c.align.fas
    /home/minit/nanopore/tools/extract-gene.na.all.sh ${BASENAME}.trim.c.align.fas

    for i in ${BASENAME}.trim.c.align.*.?a.csv
      do 
      export BASE2=`basename $i .csv`
      export DIR2=`dirname $i`
      /home/minit/nanopore/tools/summary.pl $i > ${DIR2}/${BASE2}.summary.csv
    done

    /home/minit/nanopore/tools/genotype.fl.pl ${BASENAME}.trim.c.align.fas barcode${var} > ${BASENAME}.trim.c.align.genotype.fas

    for i in ${BASENAME}.trim.c.align.*-geno.??.csv ${BASENAME}.trim.c.align.v?.??.csv ${BASENAME}.trim.c.align.??-??.??.csv ${BASENAME}.trim.c.align.tfp-??.??.csv
      do 
      export BASE3=`basename $i .csv`
      export DIR3=`dirname $i`
      /home/minit/nanopore/tools/summary2geno.pl $i barcode${var} > ${DIR3}/${BASE3}.summary.fas
    done

    for i in ${BASENAME}.trim.c.align.*-geno.??.summary.csv ${BASENAME}.trim.c.align.v?.??.summary.csv ${BASENAME}.trim.c.align.??-??.??.summary.csv ${BASENAME}.trim.c.align.tfp-??.??.summary.csv
      do 
      export BASE4=`basename $i .csv`
      export DIR4=`dirname $i`
      /home/minit/nanopore/tools/summary-geno2csv.pl $i > ${DIR4}/${BASE4}.geno.csv
    done

    for i in pr rt in prin ca ma gp120; do /home/minit/nanopore/tools/make-consensus.pl ${BASENAME}.trim.c.align.${i}.na.summary.csv barcode${var} > ${BASENAME}.trim.c.align.${i}.na.cons.fas; done
  fi
done

cd ${CURDIR}/


echo "Run finished"



