#!/bin/bash
# Step 1: Remove undesirable characters from filenames
remov_char1=' '
subst_char1='-'
for filerename in /home/intuitive/trash/*.*; do
    mv "$filerename" "${filerename//$remov_char1/$subst_char1}"
done

remov_char2='\'
subst_char2='-'
for filerename in /home/intuitive/trash/*.*; do
    mv "$filerename" "${filerename//$remov_char2/$subst_char2}"
done

remov_char3='/'
subst_char3='-'
for filerename in /home/intuitive/trash/*.*; do
    mv "$filerename" "${filerename//$remov_char3/$subst_char3}"
done

# Step 2: Remove old CSV and diagnostic file to prevent duplicate entries from previous script run
rm /home/intuitive/trash/final/filelist.csv
rm /home/intuitive/trash/final/humanlist.txt

# Step 3: Create required directories
mkdir /home/intuitive/trash/final/
mkdir /home/intuitive/trash/processed/

# Step 4: The first line gets the metadata from any existing MP4 files in the folder without converting them
for k in /home/intuitive/trash/*.mp4; do ffmpeg -y -i "$k" -f ffmetadata "${k%.*}.dat"; done
for k in /home/intuitive/trash/*.avi; do ffmpeg -y -i "$k" -f ffmetadata "${k%.*}.dat" -movflags +faststart "${k%.*}"; rm "$k"; done
for k in /home/intuitive/trash/*.mov; do ffmpeg -y -i "$k" -f ffmetadata "${k%.*}.dat" -movflags +faststart "${k%.*}"; rm "$k"; done
for k in /home/intuitive/trash/*.flv; do ffmpeg -y -i "$k" -f ffmetadata "${k%.*}.dat" -movflags +faststart "${k%.*}"; rm "$k"; done
for k in /home/intuitive/trash/*.wmv; do ffmpeg -y -i "$k" -f ffmetadata "${k%.*}.dat" -movflags +faststart "${k%.*}"; rm "$k"; done
for k in /home/intuitive/trash/*.m4v; do ffmpeg -y -i "$k" -f ffmetadata "${k%.*}.dat" -movflags +faststart "${k%.*}"; rm "$k"; done

# Step 5: Extract relevant fields from raw ffmpeg metadata output
for d in `find /home/intuitive/trash/*.mp4 -type f \( ! -path '*/final/*' ! -path '*/processed/*' ! -path '*/@eaDir/*' ! -path '*/.DS_Store/*' \)`; do echo $d | sed 's!/home/intuitive/trash/!!' > "${d%}.meta1"; done;
for e in `find /home/intuitive/trash/*.dat -type f \( ! -path '*/final/*' ! -path '*/processed/*' ! -path '*/@eaDir/*' ! -path '*/.DS_Store/*' \)`; do awk '/title=/ {print; count++; if (count=1) exit}' $e | sed 's!title=!!' > "${e%}.meta2"; done
for f in `find /home/intuitive/trash/*.dat -type f \( ! -path '*/final/*' ! -path '*/processed/*' ! -path '*/@eaDir/*' ! -path '*/.DS_Store/*' \)`; do awk '/comment=/ {print; count++; if (count=1) exit}' $f | sed 's!comment=!!' > "${f%}.meta3"; done
for g in `find /home/intuitive/trash/*.mp4 -type f \( ! -path '*/final/*' ! -path '*/processed/*' ! -path '*/@eaDir/*' ! -path '*/.DS_Store/*' \)`; do date "+%Y-%m-%d" -r $g > "${g%}.meta4"; done;

mv /home/intuitive/trash/*.dat /home/intuitive/trash/final/
mv /home/intuitive/trash/*.meta1 /home/intuitive/trash/final/
mv /home/intuitive/trash/*.meta2 /home/intuitive/trash/final/
mv /home/intuitive/trash/*.meta3 /home/intuitive/trash/final/
mv /home/intuitive/trash/*.meta4 /home/intuitive/trash/final/
mv /home/intuitive/trash/*.mp4 /home/intuitive/trash/final/

# Step 6: Generate sort file to store delimited values from MP4 files
for w in `find /home/intuitive/trash/final/*.meta1 -type f`; do a=$(cat $w); echo -n "\"$a\"|" >> /home/intuitive/trash/final/filelist1.sort; done;
echo "" >> /home/intuitive/trash/final/filelist1.sort;
for x in `find /home/intuitive/trash/final/*.meta2 -type f`; do b=$(cat $x); echo -n "\"$b\"|" >> /home/intuitive/trash/final/filelist1.sort; done;
echo "" >> /home/intuitive/trash/final/filelist1.sort;
for y in `find /home/intuitive/trash/final/*.meta3 -type f`; do c=$(cat $y); echo -n "\"$c\"|" >> /home/intuitive/trash/final/filelist1.sort; done;
echo "" >> /home/intuitive/trash/final/filelist1.sort;
for z in `find /home/intuitive/trash/final/*.meta4 -type f`; do d=$(cat $z); echo -n "\"$d\"|" >> /home/intuitive/trash/final/filelist1.sort; done;

# Step 7: Generate CSV file. Count MP4 files, cut incremementing column on each pass then append to CSV
vidcount=$(ls -l /home/intuitive/trash/final/*.mp4 | grep -v ^l | wc -l)
for v in $(seq 1 $vidcount); do cut -d "|" -f $v /home/intuitive/trash/final/filelist1.sort | tr '\n' ',' >> /home/intuitive/trash/final/filelistpre1.csv; echo "" >> /home/intuitive/trash/final/filelistpre1.csv; done

# FIX: Remove any commas from end of lines
cat /home/intuitive/trash/final/filelistpre1.csv | sed 's/[,^t]*$//' > /home/intuitive/trash/final/filelist.csv

# Step 8: Create dummy metafiles for remaining (non-mp4) files
for dd in `find /home/intuitive/trash/*.* -type f \( ! -path '*/final/*' ! -path '*/processed/*' ! -path '*/@eaDir/*' ! -path '*/.DS_Store/*' ! -path '*/*.meta1A*' ! -path '*/*.meta2A*' ! -path '*/*.meta3A*' ! -path '*/*.meta4A*' \)`; do echo $dd | sed 's!/home/intuitive/trash/!!' > "${dd%}.meta1A"; touch "${dd%}.meta2A"; touch "${dd%}.meta3A"; touch "${dd%}.meta4A"; done;

mv /home/intuitive/trash/*.meta1A /home/intuitive/trash/final/
mv /home/intuitive/trash/*.meta2A /home/intuitive/trash/final/
mv /home/intuitive/trash/*.meta3A /home/intuitive/trash/final/
mv /home/intuitive/trash/*.meta4A /home/intuitive/trash/final/

# Step 9: Append sort file to store delimited values for remaining files
for ww in `find /home/intuitive/trash/final/*.meta1A -type f`; do aa=$(cat $ww); echo -n "\"$aa\"|" >> /home/intuitive/trash/final/filelist2.sort; done;
echo "" >> /home/intuitive/trash/final/filelist2.sort;
for xx in `find /home/intuitive/trash/final/*.meta2A -type f`; do bb=$(cat $xx); echo -n "\"$bb\"|" >> /home/intuitive/trash/final/filelist2.sort; done;
echo "" >> /home/intuitive/trash/final/filelist2.sort;
for yy in `find /home/intuitive/trash/final/*.meta3A -type f`; do cc=$(cat $yy); echo -n "\"$cc\"|" >> /home/intuitive/trash/final/filelist2.sort; done;
echo "" >> /home/intuitive/trash/final/filelist2.sort;
for zz in `find /home/intuitive/trash/final/*.meta4A -type f`; do dd=$(cat $zz); echo -n "\"$dd\"|" >> /home/intuitive/trash/final/filelist2.sort; done;

# Step 10: Count remaining files, cut incremementing column on each pass then append to CSV
filecount=$(ls -l /home/intuitive/trash/*.* | grep -v ^l | wc -l)
for vv in $(seq 1 $filecount); do cut -d "|" -f $vv /home/intuitive/trash/final/filelist2.sort | tr '\n' ',' >> /home/intuitive/trash/final/filelistpre2.csv; echo "" >> /home/intuitive/trash/final/filelistpre2.csv; done

# FIX: Remove any commas from end of lines and append to CSV
cat /home/intuitive/trash/final/filelistpre2.csv | sed 's/[,^t]*$//' >> /home/intuitive/trash/final/filelist.csv

# FINAL CLEAN
rm /home/intuitive/trash/final/*.meta1
rm /home/intuitive/trash/final/*.meta2
rm /home/intuitive/trash/final/*.meta3
rm /home/intuitive/trash/final/*.meta4
rm /home/intuitive/trash/final/*.meta1A
rm /home/intuitive/trash/final/*.meta2A
rm /home/intuitive/trash/final/*.meta3A
rm /home/intuitive/trash/final/*.meta4A
rm /home/intuitive/trash/final/*.dat
rm /home/intuitive/trash/final/filelist1.sort
rm /home/intuitive/trash/final/filelist2.sort
rm /home/intuitive/trash/final/filelistpre1.csv
rm /home/intuitive/trash/final/filelistpre2.csv

# Step 11: Move remaining files to final folder
mv /home/intuitive/trash/*.* /home/intuitive/trash/final/

# Step 12: Generate two filelists for diagnostic purposes
vidcount=$(ls -l /home/intuitive/trash/final/*.mp4 | grep -v ^l | wc -l)
totalcount=$(ls -l /home/intuitive/trash/final/*.* | grep -v ^l | wc -l)
find /home/intuitive/trash/final/*.* -type f | sed 's!/home/intuitive/trash/final!!' > /home/intuitive/trash/final/humanlist.txt
find /home/intuitive/trash/final/*.mp4 -type f | sed 's!/home/intuitive/trash/final!!' > /home/intuitive/trash/final/filelist.txt
echo "-----------------------------------------------" >> /home/intuitive/trash/final/humanlist.txt
echo "*** CSV FILE:" `date "+%Y/%m/%d %H:%M:%S" -r /home/intuitive/trash/final/filelist.csv` >> /home/intuitive/trash/final/humanlist.txt
echo "*** THISFILE:" `date "+%Y/%m/%d %H:%M:%S"` >> /home/intuitive/trash/final/humanlist.txt
echo "*** MP4COUNT:" $vidcount >> /home/intuitive/trash/final/humanlist.txt
echo "*** TOTALCOUNT:" $totalcount >> /home/intuitive/trash/final/humanlist.txt
echo "-----------------------------------------------" >> /home/intuitive/trash/final/humanlist.txt

# TODO
# Implement file lock check using 'lsof -t ' to ensure that video files can safely be moved (not used by SMB or AFP processes)
