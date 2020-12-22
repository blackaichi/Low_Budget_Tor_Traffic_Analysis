#!/bin/bash

cp /root/tma/httpdump/aux.txt /root/tma/httpdump/aux2.txt
cp /root/tma/httpdump/aux.txt "/root/tma/logs/SG_`date +%Y-%m-%d_%T`.txt"
rm /root/tma/httpdump/aux.txt
ps -ef | grep httpdump | grep -v grep | awk '{print $2}' | xargs kill
sudo /root/tma/httpdump/httpdump -level tma -output /root/tma/httpdump/aux.txt &
