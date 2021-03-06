#$ -S /bin/bash
#$ -cwd
#$ -N train_dREG.SVR
#$ -o train_dREG.SVR.out.$JOB_ID
#$ -j y
#$ -pe bscb 6
#$ -M dankoc@gmail.com
#$ -m be
#$ -l h_rt=72:00:00
#$ -q long_term.q

STARTDIR=`pwd`

## Copy files to scratch space (/workdir and /SSD).
SCRATCH=/SSD/cgd24.train_SVR/
mkdir $SCRATCH
cp /home/cgd24/projects/tss_detector/train_svm/train_svm.R $SCRATCH ## 
cp /home/cgd24/projects/tss_detector/andre_hmm/hg19.k562.new_hmm2b.post2.bed $SCRATCH ## Andre's HMM Predictions
cp /home/cgd24/projects/tss_detector/data/GencodeMerge.IntersectOpStrand.bed $SCRATCH ## Gene overlap files
cp /home/cgd24/projects/tss_detector/data/k562/chromHmm.k562.enh.prom.bed.gz $SCRATCH ## Ernst chromHMM.
cp /home/cgd24/projects/tss_detector/data/k562/k562.dnase.UW.DUKE.inters.bed.gz $SCRATCH ## Ernst chromHMM.
cp /home/cgd24/projects/tss_detector/data/k562/K562_unt.sort.bed.gz_*.bw $SCRATCH ## bigWig files.
cd $SCRATCH

## Intersect w/ DNase.
gunzip k562.dnase.UW.DUKE.inters.bed.gz 
cat hg19.k562.new_hmm2b.post2.bed | awk 'BEGIN{OFS="\t"} {print $1,$2-100,$3+100}' | bedops --merge - | bedmap --echo --count k562.dnase.UW.DUKE.inters.bed - | grep -v "|0" | sed "s/|/\t/g" > hg19.k562.new_hmm2b.post2.dnase.bed
head hg19.k562.new_hmm2b.post2.dnase.bed


## Run R.
R --no-save < train_svm.R

## Copy data files back.
cp TrainingSet.bed $STARTDIR
cp TrainIndx.Rflat $STARTDIR
cp *.bedGraph $STARTDIR
cp *.RData $STARTDIR

rm -rf $SCRATCH
