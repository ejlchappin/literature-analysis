#!/bin/bash

#remove headers from scopus files
for f in scopus*.csv
do
 cat $f | sed '1d' > temp_noheader_$f
done

#make one file with all scopus results
cat temp_noheader_scopus* > temp_csv_complete.csv

echo Found `cat temp_csv_complete.csv | wc -l` publications.

#resolve commas in files, make it tab delimited.
cat temp_csv_complete.csv | awk -F\" '{for(i=1;i<=NF;i+=2) {gsub(",", "\t", $i)}}1' > temp_csv_tabbed

# split the complete csv in files per publication 
split -d -l 1 -a 5 temp_csv_tabbed temp_csv_split

# delete the previous edgelist.
rm edgelist.edges

# for each of the files containing the info of one publication
for x in temp_csv_split*
do
   # store the title (column 2), the ref's (column 23) and remove leading and trailing white spaces.
   awk -F"\t" '{print $1 $2 $3 $4 $5 $6}' $x | sed -e 's/^ *//g;s/ *$//g' > temp_firstline
   awk -F"\t" '{print $23}' $x | sed -e 's/^ *//g;s/ *$//g' > temp_reflines

   # split the references on lines, convert to lower case, just to be sure, remove leading and trailing white spaces again.
   sed 's/;/\n/g' temp_reflines | tr A-Z a-z | sed -e 's/^ *//g;s/ *$//g' > temp_reflines_splitlines

   # for each ref, store reference \tab publication in an edge list
   cat temp_reflines_splitlines | while read line ; do
	echo -e $line "\t" `cat temp_firstline` >> edgelist.edges
   done 
done

# remove all temp files.
rm temp*
echo Created an list with `cat edgelist.edges | wc -l` edges between publications.
