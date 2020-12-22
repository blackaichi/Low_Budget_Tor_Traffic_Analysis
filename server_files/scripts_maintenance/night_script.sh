#!/bin/bash

ps -ef | grep checkMem  | grep -v grep | awk '{print $2}' | xargs kill

bash /root/tma/scripts/parse_files.sh 

bash /root/tma/scripts/checkMem.sh
