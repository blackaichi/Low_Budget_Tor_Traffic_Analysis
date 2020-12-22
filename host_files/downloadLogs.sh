#!/bin/bash

server1="root@51.195.166.161"
server2="root@142.44.156.131"
server3="root@139.99.133.215"
server4="root@139.99.88.87"
serverPath="/root/tma/logs/*"
hostPath="/hdd/TMA/Logs/"

function EU {
    if [ `ssh $server1 ls /root/tma/logs | wc -l` -eq "0" ] 
    then
	echo "There are no logs! EU"
    else
    	scp $server1:$serverPath $hostPath
    	ssh $server1 rm $serverPath 
    fi
}

function NA {
    if [ `ssh $server2 ls /root/tma/logs | wc -l` -eq "0" ] 
    then
		echo "There are no logs! NA"
    else
    	scp $server2:$serverPath $hostPath
    	ssh $server2 rm $serverPath 
    fi
}

function AU {
    if [ `ssh $server3 ls /root/tma/logs | wc -l` -eq "0" ] 
    then
		echo "There are no logs! AU"
    else
    	scp $server3:$serverPath $hostPath
    	ssh $server3 rm $serverPath 
    fi
}

function SG {
    if [ `ssh $server4 ls /root/tma/logs | wc -l` -eq "0" ] 
    then
		echo "There are no logs! EU"
    else
    	scp $server4:$serverPath $hostPath
    	ssh $server4 rm $serverPath 
    fi
}

if [ "$#" -eq "0" ] 
then
    EU
    NA
    AU
    SG
    echo "Done!"
elif [ "$1" == "EU" ]
then
    EU
    echo "Done!"
elif [ "$1" == "NA" ]
then
    NA
    echo "Done!"
elif [ "$1" == "AU" ]
then
    AU
    echo "Done!"
elif [ "$1" == "SG" ]
then
    SG
    echo "Done!"
else 
    echo "usage: \nno arguments to download all \n or put the argument EU,NA,AU or SG \n to download specific logs"
fi

