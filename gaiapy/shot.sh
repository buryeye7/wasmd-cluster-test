#!/bin/bash

if [ $# -eq 0 ];then
    echo "Please param, transfer or execute"
    exit 0
fi

./kill-transfer-to.sh
rm -rf ./tps-log/transfer-to-log*

i=0
while read line
do
    param1=$(echo $line | awk -F' ' '{print $1}')
    param2=$(echo $line | awk -F' ' '{print $2}')
    param3=$(echo $line | awk -F' ' '{print $3}')
    echo $param1 $param2 $param3
    if [ $1 == "transfer" ];then 
        echo "transfer start"
        ./transfer-to.py $param1 $param2 $param3 >> ./tps-log/transfer-to-log$i.txt &    
    else
        echo "wasm start"
        param4=$(echo $line | awk -F' ' '{print $4}')
        ./execute-wasm-to.py $param1 $param2 $param3 $param4 >> ./tps-log/transfer-to-log$i.txt &    
    fi
    i=$((i + 1))
done < test-info-after-mempool-full.txt
