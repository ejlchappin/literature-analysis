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

# delete the previous edgelist.
rm authors.edges

# store the authors (column 1), and the ref's (column 23) and remove leading and trailing white spaces.
cat temp_csv_tabbed | awk -F"\t" '{print $1}'  | sed -e 's/^ *//g;s/ *$//g' | sed 's/;/\n/g' | tr A-Z a-z | sed -e 's/^ *//g;s/ *$//g' | tr A-Z a-z | sed 's/\.//g'> temp_primary
cat temp_csv_tabbed | awk -F"\t" '{print $23}' | sed -e 's/^ *//g;s/ *$//g' | sed 's/;/\n/g' | tr A-Z a-z | sed -e 's/^ *//g;s/ *$//g' | tr A-Z a-z > temp_secondary

#secondary authors: convert the double spaces.
cat temp_secondary | sed 's/\"//g' | sed 's/(.*//' | sed 's/\.,/;/g' | sed 's/,//g' | sed 's/;/,/g' > temp_secondary_step2

#If no comma: delete line, remove parts longer then 20 charachters
cat temp_secondary_step2 | sed -n -e '/,/p' | sed 's/[^,]\{20,\}//g' | sed '/^$/d'  | sed 's/\.//g' > temp_secondary_step3

# combine authors (correct the second)
cat temp_primary > temp_authors_long
cat temp_secondary_step3 >> temp_authors_long

echo `cat temp_authors_long | wc -l` "to process"
touch temp_authors
while read x
do         
   first=`echo $x | sed 's/,/\n/g' | sed -n 1p`
   second=`echo $x | sed 's/,/\n/g' | sed -n 2p`
   third=`echo $x | sed 's/,/\n/g' | sed -n 3p`
   fourth=`echo $x | sed 's/,/\n/g' | sed -n 4p`
   fifth=`echo $x | sed 's/,/\n/g' | sed -n 5p`
   sixth=`echo $x | sed 's/,/\n/g' | sed -n 6p`
   seventh=`echo $x | sed 's/,/\n/g' | sed -n 7p`
   eigth=`echo $x | sed 's/,/\n/g' | sed -n 8p`

   # for each author combination, store author \tab author in the temp_authors list
   if [ -n "$first" ]; then 	
     if [ -n "$second" ]; then
       echo $first "\t" $second >> temp_authors
       if [ -n "$third" ]; then
         echo $first "\t" $third >> temp_authors
         echo $second "\t" $third >> temp_authors
         if [ -n "$fourth" ]; then
           echo $first "\t" $fourth >> temp_authors
	   echo $second "\t" $fourth >> temp_authors
	   echo $third "\t" $fourth >> temp_authors
           if [ -n "$fifth" ]; then		
	     echo $first "\t" $fifth >> temp_authors
 	     echo $second "\t" $fifth >> temp_authors
 	     echo $third "\t" $fifth >> temp_authors
	     echo $fourth "\t" $fifth >> temp_authors
  	     if [ -n "$sixth" ]; then		
               echo $first "\t" $sixth >> temp_authors
               echo $second "\t" $sixth >> temp_authors
               echo $third "\t" $sixth >> temp_authors
               echo $fourth "\t" $sixth >> temp_authors
               echo $fifth "\t" $sixth >> temp_authors
               if [ -n "$seventh" ]; then		
                 echo $first "\t" $seventh >> temp_authors
                 echo $second "\t" $seventh >> temp_authors
                 echo $third "\t" $seventh >> temp_authors
                 echo $fourth "\t" $seventh >> temp_authors
                 echo $fifth "\t" $seventh >> temp_authors
                 echo $sixth "\t" $seventh >> temp_authors
                 if [ -n "$eigth" ]; then	
		   echo $first "\t" $eigth >> temp_authors
		   echo $second "\t" $eigth >> temp_authors
		   echo $third "\t" $eigth >> temp_authors
   		   echo $fourth "\t" $eigth >> temp_authors
		   echo $fifth "\t" $eigth >> temp_authors
		   echo $sixth "\t" $eigth >> temp_authors
		   echo $seventh "\t" $eigth >> temp_authors
                 fi
	       fi
	     fi
           fi
         fi
       fi
     fi
   fi
done < temp_authors_long

#remove leading and trailing spaces, replace inner spaces by dashes.
cat temp_authors | sed -e 's/^ *//g;s/ *$//g' | sed 's/\ /-/g' > authors.edges

echo Created an list with `cat authors.edges | wc -l` edges between authors.
rm temp*

