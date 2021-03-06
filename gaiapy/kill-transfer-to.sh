#!/bin/bash

ps -ef | grep transfer-to > /tmp/transfer-to.txt

while read line
do
    if [[ $line == *"auto"* ]];then
        continue
    fi
    process=$(echo $line | awk -F' ' '{print $2}')
    kill -9 $process
done < /tmp/transfer-to.txt
