#!/bin/bash

ps -ef | grep transfer | awk -F' ' '{print $2}' | while read line
do
    echo $line
    if [[ $line == *"auto"* ]];then
        continue
    fi
    kill -9 $line
done

