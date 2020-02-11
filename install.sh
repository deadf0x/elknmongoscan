#!/bin/bash

mkdir /opt/scan
cp -p brute.sh /opt/scan/
cp -p scan.sh /opt/scan/
cp -p control /opt/scan/
cp -p targets /opt/scan/



cp -p ./elscan.service /etc/systemd/system/
chown root:root /etc/systemd/system/elscan.service
systemctl daemon-reload



