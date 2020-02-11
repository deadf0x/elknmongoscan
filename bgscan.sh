#!/bin/bash

tgkey=""
chat_id=""
proxy_ip=""
proxy_login=""
proxy_pass=""
proxy_port=""


#Check parametrs
if [ -n "$2" ]
	then
	echo masscan port:$1 hosts:$2
else
	echo "No parameters found. "
	echo "Usage: ./scanbg.sh 3391 host(/s)_list"
	echo "Required: masscan grep awk curl screen python"
	exit
fi


#Clear variable for filename
out=$( echo $2 | sed 's/\///g' | sed 's/\,//g' | sed 's/\.//g' )

#backup outfile if same targets
#mv -f $out.outbg $out.outbg_`date +%s`

#clean outfile
#echo "" > $out.outbg 

#Scan targets in background

#if [[ "$1" == "3391" ]]

#	then masscan -p U:$1 -iL $2 -oG $out.outbg &
#	sleep 300
#fi


#while ps -aux | grep masscan | grep -v "grep" | awk {'print $2'}
#do

        grep -Eo '([0-9]*\.){3}[0-9]*' $out.outbg  | while read line
	
	        do
			 python check.py $line 3391

	        done


#done

#check after masscan stopped
while grep -qEo '([0-9]*\.){3}[0-9]*' $out.outbg
do

grep -Eo '([0-9]*\.){3}[0-9]*' $targets  | while read line

                do
                         python check.py $line 3391

                done

done



#send resilts - hosts without passwords on access

#if [[ $(find ./ -name elastic.txt -type f -size +1 2>/dev/null) ]];
#
 #       then  curl -v --socks5 $proxy_ip:$proxy_port -U $proxy_login:$proxy_pass -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 https://api.telegram.org/bot$tgkey/sendDocument -F document=@elastic.txt -F "chat_id=$chat_id"
# 
#fi

