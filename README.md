# ELK and MGDB scanner

Req.: hydra, nmap, masscan, custom nmap script: elastic.nse (copy to nmap script folder, e.g - /usr/share/nmap/scripts/)

Usage:  ./scan.sh port host(s), example:./scan.sh 27017 192.168.0.0/24,127.0.0.1,172.16.0.1

If you want bruteforce secured elk instance after scan, fill usernames and passwords files:
file ./LOGINS for usernames (default elastic)
file ./PASSWORDS for passwords

#TODO
- Mongodb bruteforce
- Telegram alerts:
	findings
	succefull bruteforced

