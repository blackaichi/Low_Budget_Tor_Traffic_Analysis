#!/bin/bash

minimumMem=400

while true; do

    totalk=$(awk '/^MemFree:/{print $2}' /proc/meminfo)
    if [ "$totalk" -lt "$minimumMem" ]
    then
        bash /root/tma/scripts/parse_files.sh
    fi

    sleep 30
done
