# ELK and MGDB scanner

cd /opt
git clone git@github.com:medlynx/new.git
cd new && ./install.sh

Req.: hydra, nmap, masscan, custom nmap script: elastic.nse (copy to nmap script folder, e.g - /usr/share/nmap/scripts/)
Install custom hydra build:

apt install masscan nmap screen curl libmongoc-dev ; (enable mongo support)
git clone https://github.com/vanhauser-thc/thc-hydra.git;
cd thc-hydra;
./configure --prefix=/opt;
 make install;

