#!/bin/bash

#Check parametrs
if [ -n "$2" ]
	then
	echo masscan port:$1 hosts:$2
else
	echo "No parameters found. "
	echo "Usage: ./scan.sh port host(/s) Example: ./scan.sh 9200 192.168.0.0/24 OR  ./scan.sh 9200 192.168.0.0/24,172.16.0.0/16 ./scan.sh 27017 192.168.0.0/24,172.16.0.0/16"
	echo "Required: masscan nmap grep awk"
	exit
fi

#Clear report file

if [[ "$1" == "9200" ]]; then
echo "" > elastic.txt
fi

if [[ "$1" == "27017" ]]; then
echo "" > mongodb.txt
fi


#Clear variable for filename
out=$( echo $2 | sed 's/\///g' | sed 's/\,//g' | sed 's/\.//g' )
echo $out 

#Scan targets
masscan -p $1 $2 -oG $out.out

#Find hosts with opened target ports
grep open $out.out | awk {'print $2'} > map.input

#ELK_check
if [[ "$1" == "9200" ]]; then

	cat map.input | while read line
do
	if curl -X GET "$line:9200/" | grep "You Know, for Search";
		then echo $line >> elastic.txt; 
		nmap $line -p$1 --script=elastic | grep "|">> elastic.txt
	fi
done
fi

#MGDB_check

if [[ "$1" == "27017" ]]; then

        cat map.input | while read line
do

        if curl -X GET "$line:27017/" | grep "MongoDB";
                then echo $line >> mongodb.txt;
		 nmap $line -p$1 --script=mongodb-databases.nse | grep "|">> mongodb.txt
        fi
done
fi





