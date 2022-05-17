#!/usr/bin/env bash

# Set custom variables here
BASEDIR="/home/intuitive/videos"
FINALDIR="/home/intuitive/videos/processed"

# Step 1: Remove undesirable characters from filenames
remov_char1=' '
subst_char1='-'
for filerename in ${BASEDIR}/*.*; do
    mv "$filerename" "${filerename//$remov_char1/$subst_char1}"
done

remov_char2='\'
subst_char2='-'
for filerename in ${BASEDIR}/*.*; do
    mv "$filerename" "${filerename//$remov_char2/$subst_char2}"
done

remov_char3='/'
subst_char3='-'
for filerename in ${BASEDIR}/*.*; do
    mv "$filerename" "${filerename//$remov_char3/$subst_char3}"
done

# Step 2: Remove old CSV and diagnostic file to prevent duplicate entries from previous script run
rm ${BASEDIR}/final/filelist.csv
rm ${BASEDIR}/final/humanlist.txt

# Step 3: Create required directories
mkdir ${BASEDIR}/final/
mkdir ${FINALDIR}

# Step 4: The first line gets the metadata from any existing MP4 files in the folder without converting them
for k in ${BASEDIR}/*.mp4; do ffmpeg -y -i "$k" -f ffmetadata "${k%.*}.dat"; done
for k in ${BASEDIR}/*.avi; do ffmpeg -y -i "$k" -f ffmetadata "${k%.*}.dat" -movflags +faststart "${k%.*}"; rm "$k"; done
for k in ${BASEDIR}/*.mov; do ffmpeg -y -i "$k" -f ffmetadata "${k%.*}.dat" -movflags +faststart "${k%.*}"; rm "$k"; done
for k in ${BASEDIR}/*.flv; do ffmpeg -y -i "$k" -f ffmetadata "${k%.*}.dat" -movflags +faststart "${k%.*}"; rm "$k"; done
for k in ${BASEDIR}/*.wmv; do ffmpeg -y -i "$k" -f ffmetadata "${k%.*}.dat" -movflags +faststart "${k%.*}"; rm "$k"; done
for k in ${BASEDIR}/*.m4v; do ffmpeg -y -i "$k" -f ffmetadata "${k%.*}.dat" -movflags +faststart "${k%.*}"; rm "$k"; done

# Step 5: Extract metadata: filename, title, comment, modified date
for d in `find ${BASEDIR}/*.mp4 -type f \( ! -path '*/final/*' ! -path '*/processed/*' ! -path '*/@eaDir/*' ! -path '*/.DS_Store/*' \)`; do echo $d | sed 's!/home/intuitive/trash/!!' > "${d%}.meta1"; done;
for e in `find ${BASEDIR}/*.dat -type f \( ! -path '*/final/*' ! -path '*/processed/*' ! -path '*/@eaDir/*' ! -path '*/.DS_Store/*' \)`; do awk '/title=/ {print; count++; if (count=1) exit}' $e | sed 's!title=!!' > "${e%}.meta2"; done
for f in `find ${BASEDIR}/*.dat -type f \( ! -path '*/final/*' ! -path '*/processed/*' ! -path '*/@eaDir/*' ! -path '*/.DS_Store/*' \)`; do awk '/comment=/ {print; count++; if (count=1) exit}' $f | sed 's!comment=!!' > "${f%}.meta3"; done
for g in `find ${BASEDIR}/*.mp4 -type f \( ! -path '*/final/*' ! -path '*/processed/*' ! -path '*/@eaDir/*' ! -path '*/.DS_Store/*' \)`; do date "+%Y-%m-%d" -r $g > "${g%}.meta4"; done;

mv ${BASEDIR}/*.dat ${BASEDIR}/final/
mv ${BASEDIR}/*.meta1 ${BASEDIR}/final/
mv ${BASEDIR}/*.meta2 ${BASEDIR}/final/
mv ${BASEDIR}/*.meta3 ${BASEDIR}/final/
mv ${BASEDIR}/*.meta4 ${BASEDIR}/final/
cp ${BASEDIR}/*.mp4 ${BASEDIR}/final/

# Step 6: Generate temporary files to store delimited values from MP4 files
for w in `find ${BASEDIR}/final/*.meta1 -type f`; do a=$(cat $w); echo -n "\"$a\"|" >> ${BASEDIR}/final/filelist1.sort; done;
echo "" >> ${BASEDIR}/final/filelist1.sort;
for x in `find ${BASEDIR}/final/*.meta2 -type f`; do b=$(cat $x); echo -n "\"$b\"|" >> ${BASEDIR}/final/filelist1.sort; done;
echo "" >> ${BASEDIR}/final/filelist1.sort;
for y in `find ${BASEDIR}/final/*.meta3 -type f`; do c=$(cat $y); echo -n "\"$c\"|" >> ${BASEDIR}/final/filelist1.sort; done;
echo "" >> ${BASEDIR}/final/filelist1.sort;
for z in `find ${BASEDIR}/final/*.meta4 -type f`; do d=$(cat $z); echo -n "\"$d\"|" >> ${BASEDIR}/final/filelist1.sort; done;

# Step 7: Generate CSV file. Count MP4 files, cut incremementing column on each pass then append to CSV
vidcount=$(ls -l ${BASEDIR}/final/*.mp4 | grep -v ^l | wc -l)
for v in $(seq 1 $vidcount); do cut -d "|" -f $v ${BASEDIR}/final/filelist1.sort | tr '\n' ',' >> ${BASEDIR}/final/filelistpre1.csv; echo "" >> ${BASEDIR}/final/filelistpre1.csv; done

# FIX: Remove leftover commas from end of lines
sed -i 's/[,^t]*$//' ${BASEDIR}/final/filelistpre1.csv

# Copy the temporary CSV into a new file
cp ${BASEDIR}/final/filelistpre1.csv ${BASEDIR}/final/filelist.csv

# Step 8: Create dummy metafiles for remaining (non-mp4) files
for dd in `find ${BASEDIR}/*.* -type f \( ! -path '*.mp4' ! -path '*/final/*' ! -path '*/processed/*' ! -path '*/@eaDir/*' ! -path '*/.DS_Store/*' ! -path '*/*.meta1A*' ! -path '*/*.meta2A*' ! -path '*/*.meta3A*' ! -path '*/*.meta4A*' \)`; do echo $dd | sed 's!/home/intuitive/trash/!!' > "${dd%}.meta1A"; touch "${dd%}.meta2A"; touch "${dd%}.meta3A"; touch "${dd%}.meta4A"; done;

mv ${BASEDIR}/*.meta1A ${BASEDIR}/final/
mv ${BASEDIR}/*.meta2A ${BASEDIR}/final/
mv ${BASEDIR}/*.meta3A ${BASEDIR}/final/
mv ${BASEDIR}/*.meta4A ${BASEDIR}/final/

# Step 9: Append sort file to store delimited values for remaining files
for ww in `find ${BASEDIR}/final/*.meta1A -type f`; do aa=$(cat $ww); echo -n "\"$aa\"|" >> ${BASEDIR}/final/filelist2.sort; done;
echo "" >> ${BASEDIR}/final/filelist2.sort;
for xx in `find ${BASEDIR}/final/*.meta2A -type f`; do bb=$(cat $xx); echo -n "\"$bb\"|" >> ${BASEDIR}/final/filelist2.sort; done;
echo "" >> ${BASEDIR}/final/filelist2.sort;
for yy in `find ${BASEDIR}/final/*.meta3A -type f`; do cc=$(cat $yy); echo -n "\"$cc\"|" >> ${BASEDIR}/final/filelist2.sort; done;
echo "" >> ${BASEDIR}/final/filelist2.sort;
for zz in `find ${BASEDIR}/final/*.meta4A -type f`; do dd=$(cat $zz); echo -n "\"$dd\"|" >> ${BASEDIR}/final/filelist2.sort; done;

# Step 10: Count remaining files, cut incremementing column on each pass then append to CSV
filecount=$(ls -l ${BASEDIR}/*.* | grep -v ^l | wc -l)
for vv in $(seq 1 $filecount); do cut -d "|" -f $vv ${BASEDIR}/final/filelist2.sort | tr '\n' ',' >> ${BASEDIR}/final/filelistpre2.csv; echo "" >> ${BASEDIR}/final/filelistpre2.csv; done

# FIX: Remove any commas from end of lines and append to CSV
cat ${BASEDIR}/final/filelistpre2.csv | sed 's/[,^t]*$//' >> ${BASEDIR}/final/filelist.csv

# FINAL CLEAN
rm ${BASEDIR}/final/*.meta1
rm ${BASEDIR}/final/*.meta2
rm ${BASEDIR}/final/*.meta3
rm ${BASEDIR}/final/*.meta4
rm ${BASEDIR}/final/*.meta1A
rm ${BASEDIR}/final/*.meta2A
rm ${BASEDIR}/final/*.meta3A
rm ${BASEDIR}/final/*.meta4A
rm ${BASEDIR}/final/*.dat
rm ${BASEDIR}/final/filelist1.sort
rm ${BASEDIR}/final/filelist2.sort
rm ${BASEDIR}/final/filelistpre1.csv
rm ${BASEDIR}/final/filelistpre2.csv

# Step 11: Copy remaining files to final folder
cp ${BASEDIR}/*.* ${BASEDIR}/final/

# Step 12: Generate two filelists for diagnostic purposes
vidcount=$(ls -l ${BASEDIR}/final/*.mp4 | grep -v ^l | wc -l)
totalcount=$(ls -l ${BASEDIR}/final/*.* | grep -v ^l | wc -l)
find ${BASEDIR}/final/*.* -type f | sed 's!${BASEDIR}/final!!' > ${BASEDIR}/final/filelist.txt
echo "-----------------------------------------------" >> ${BASEDIR}/final/humanlist.txt
echo "*** CSV FILE:" `date "+%Y/%m/%d %H:%M:%S" -r ${BASEDIR}/final/filelist.csv` >> ${BASEDIR}/final/humanlist.txt
echo "*** THISFILE:" `date "+%Y/%m/%d %H:%M:%S"` >> ${BASEDIR}/final/humanlist.txt
echo "*** PROCESSED MP4:" $vidcount >> ${BASEDIR}/final/humanlist.txt
echo "*** TOTAL FILES:" $totalcount >> ${BASEDIR}/final/humanlist.txt
echo "*** EXECUTION TIME:" $SECONDS" seconds" >> ${BASEDIR}/final/humanlist.txt
echo "-----------------------------------------------" >> ${BASEDIR}/final/humanlist.txt

# TODO
# Implement file lock check using 'lsof -t ' to ensure that video files can safely be moved (not used by SMB or AFP processes)

echo "Script execution time: " $SECONDS" seconds."
