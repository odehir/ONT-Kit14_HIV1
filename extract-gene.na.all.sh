#!/bin/sh

FILE=$1
DIR=`dirname ${FILE}`
BASE=`basename ${FILE} .fas`
echo $FILE

for l in ma ca p2 nc p1 p6 pr rt gp120 gp41 vpu nef
do
  echo $l
  /home/minit/nanopore/tools/extract-gene.na.pl -O -r ${l} -i ${FILE} -o ${DIR}/${BASE}.${l}.na.csv
done
for l in in prin
do
  echo $l
  /home/minit/nanopore/tools/extract-gene.na.pl -O -m 12 -r ${l} -i ${FILE} -o ${DIR}/${BASE}.${l}.na.csv
done
for l in vif vpr tat rev
do
  echo $l
  /home/minit/nanopore/tools/extract-gene.na.pl -O -m 18 -r ${l} -i ${FILE} -o ${DIR}/${BASE}.${l}.na.csv
done
for l in v1 v2 v3 c2c5 v4 v5 ma-ca ca-p2 p2-nc nc-p1 p1-p6 tfp-pr pr-rt rt-rt rt-in
do
  echo $l
  /home/minit/nanopore/tools/extract-gene.na.pl -O -r ${l} -i ${FILE} -o ${DIR}/${BASE}.${l}.na.csv
done
for l in ma ca prrt gp120 c2c5
do
  echo $l
  /home/minit/nanopore/tools/extract-gene.na.pl -O -g -r ${l} -i ${FILE} -o ${DIR}/${BASE}.${l}-geno.na.csv
done
for l in in 
do
  echo $l
  /home/minit/nanopore/tools/extract-gene.na.pl -O -g -m 12 -r ${l} -i ${FILE} -o ${DIR}/${BASE}.${l}-geno.na.csv
done
