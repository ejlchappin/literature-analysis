#!/bin/bash

#remove headers from scopus files

for f in scopus*.csv
do
 cat $f | sed '1d' > temp_noheader_$f
done

#make one file with all scopus results
cat temp_noheader_scopus* > temp_csv_complete.csv

#resolve commas in files, remove duplicates make it tab delimited.
cat temp_csv_complete.csv | sort | uniq | awk -F\" '{for(i=1;i<=NF;i+=2) {gsub(",", "\t", $i)}}1' > temp_csv_tabbed

echo Found `cat temp_csv_tabbed | wc -l` unique publications out of `cat temp_csv_complete.csv | wc -l` in total.

# split the complete csv in files per publication 
split -d -l 1 -a 5 temp_csv_tabbed temp_csv_split

# delete the previous edgelist.
rm keywords.txt
rm keywords.edges

# for each of the files containing the info of one publication
for x in temp_csv_split*
do
   # store the keyword (column 16) and remove leading and trailing white spaces.
   awk -F"\t" '{print $16}' $x | sed -e 's/^ *//g;s/ *$//g' > temp_keywords

   # split the references on lines, convert to lower case, just to be sure, remove leading and trailing white spaces again.
   sed 's/;/\n/g' temp_keywords | tr A-Z a-z | sed -e 's/^ *//g;s/ *$//g' > temp_keywords2

   # for each ref, store the list of keywords.
   cat temp_keywords2 | while read line ; do
      if [ -n "$line" ]; then
	   #store the whole set.
      	   echo $line >> keywords.txt
      fi
   done

	   
	   #make a combi overview
      	   first=`cat temp_keywords2 | sed -n 1p`
	   second=`cat temp_keywords2 | sed -n 2p`
	   third=`cat temp_keywords2 | sed -n 3p`
	   fourth=`cat temp_keywords2 | sed -n 4p`
	   fifth=`cat temp_keywords2 | sed -n 5p`
	   sixth=`cat temp_keywords2 | sed -n 6p`
	   seventh=`cat temp_keywords2 | sed -n 7p`
	   eigth=`cat temp_keywords2 | sed -n 8p`
	
	   # for each author combination, store author \tab author in the temp_authors list
	   if [ -n "$first" ]; then 	
	     if [ -n "$second" ]; then
	       echo $first "\t" $second >> temp_keywords_combis
	       if [ -n "$third" ]; then
	         echo $first "\t" $third >> temp_keywords_combis
	         echo $second "\t" $third >> temp_keywords_combis
	         if [ -n "$fourth" ]; then
	           echo $first "\t" $fourth >> temp_keywords_combis
		   echo $second "\t" $fourth >> temp_keywords_combis
		   echo $third "\t" $fourth >> temp_keywords_combis
	           if [ -n "$fifth" ]; then		
		     echo $first "\t" $fifth >> temp_keywords_combis
	 	     echo $second "\t" $fifth >> temp_keywords_combis
	 	     echo $third "\t" $fifth >> temp_keywords_combis
		     echo $fourth "\t" $fifth >> temp_keywords_combis
	  	     if [ -n "$sixth" ]; then		
	               echo $first "\t" $sixth >> temp_keywords_combis
	               echo $second "\t" $sixth >> temp_keywords_combis
	               echo $third "\t" $sixth >> temp_keywords_combis
	               echo $fourth "\t" $sixth >> temp_keywords_combis
	               echo $fifth "\t" $sixth >> temp_keywords_combis
	               if [ -n "$seventh" ]; then		
	                 echo $first "\t" $seventh >> temp_keywords_combis
	                 echo $second "\t" $seventh >> temp_keywords_combis
	                 echo $third "\t" $seventh >> temp_keywords_combis
	                 echo $fourth "\t" $seventh >> temp_keywords_combis
	                 echo $fifth "\t" $seventh >> temp_keywords_combis
	                 echo $sixth "\t" $seventh >> temp_keywords_combis
	                 if [ -n "$eigth" ]; then	
			   echo $first "\t" $eigth >> temp_keywords_combis
			   echo $second "\t" $eigth >> temp_keywords_combis
			   echo $third "\t" $eigth >> temp_keywords_combis
	   		   echo $fourth "\t" $eigth >> temp_keywords_combis
			   echo $fifth "\t" $eigth >> temp_keywords_combis
			   echo $sixth "\t" $eigth >> temp_keywords_combis
			   echo $seventh "\t" $eigth >> temp_keywords_combis
	                 fi
		       fi
		     fi
	           fi
	         fi
	       fi
	     fi
	   fi
done

cat temp_keywords_combis | sed -e 's/^ *//g;s/ *$//g' | sed 's/\ /-/g' > keywords.edges

# sort the keywords, count and sort on occurrence, reformat so we have a csv file (removing spaces and including a tab between the occurrence and the keyword)
cat keywords.txt | sort | uniq -c -i | sed -e 's/^ *//g;s/ *$//g' | sed 's/ /\t/' | sort -n -r > keywords-count.txt

# remove all temp files.
#rm temp*

echo Created an list with `cat keywords-count.txt | wc -l` keywords and `cat keywords.edges | wc -l` links between keywords.
