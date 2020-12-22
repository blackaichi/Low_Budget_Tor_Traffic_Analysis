#!/bin/bash

j=`ls -l /root/tma/httpdump/aux.txt | cut -d' ' -f5`
k=`cat /root/tma/httpdump/size.txt`

if [ "$j" == "$k" ]
then
    ps -ef | grep httpdump | grep -v grep | awk '{print $2}' | xargs kill
    mv /root/tma/httpdump/aux.txt /root/tma/logs/SG_`date +"%Y-%m-%d_%T"`.txt
    touch /root/tma/httpdump/aux.txt
    /root/tma/httpdump/httpdump -level tma -output /root/tma/httpdump/aux.txt &
    echo 0 > /root/tma/httpdump/size.txt
else
    echo $j > /root/tma/httpdump/size.txt
fi

i=`lsof -f -- /root/tma/httpdump/aux.txt | wc -l`

if [ "$i" -eq "0" ] 
then
    mv /root/tma/httpdump/aux.txt /root/tma/logs/SG_`date +"%Y-%m-%d_%T"`.txt
    touch /root/tma/httpdump/aux.txt
    /root/tma/httpdump/httpdump -level tma -output /root/tma/httpdump/aux.txt &
fi
