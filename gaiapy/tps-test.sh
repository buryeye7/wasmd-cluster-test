#!/bin/bash

#AMOUNT=10000000000uatom
AMOUNT=10000000000

ADDRESSES=()
PRIV_KEYS=()
ACCOUNT_NUMS=()
TARGETS=()

TARGET_ADDRESS=""
SRC_PRIV_KEY=""
ACCOUNT_NUM=""

i=0
while read line
do
    if [ $i -eq 0 ];then
        TARGET_ADDRESS=$(echo $line | awk -F' ' '{print $1}')    
        SRC_PRIV_KEY=$(echo $line | awk -F' ' '{print $2}')    
        ACCOUNT_NUM=$(echo $line | awk -F' ' '{print $3}')    
    fi
    TARGETS[$i]=$(echo $line | awk -F' ' '{print $1}')    
    echo ${TARGETS[$i]}
    i=$((i + 1))
done < test-info.txt

echo "TARGETS updated"

i=0
while read line 
do
    PRIV_KEYS[$i]=$(echo $line | jq .private_key | sed "s/\"//g")
    ADDRESSES[$i]=$(echo $line | jq .address | sed "s/\"//g")
    echo "ADDRESSES[$i]" ${ADDRESSES[$i]}
    i=$((i + 1))
done < wallets.txt

echo "PRIV_KEYS updated"

TARGETS_LEN=${#TARGETS[@]}
PRIV_KEYS_LEN=${#PRIV_KEYS[@]}

rm -rf tps-log/*
rm diffs/*
touch diffs/diff.txt
for (( i=0; i < ${PRIV_KEYS_LEN}; i++ ))
do
    param1=$TARGET_ADDRESS
    param2=$SRC_PRIV_KEY
    param3=$ACCOUNT_NUM
    param4=$i
    param5=$AMOUNT
    param6=${ADDRESSES[$i]}
    echo "ADDRESSES[$i]" ${ADDRESSES[$i]}
    echo "param6 " $param6
    ./transfer-to-once.py $param1 $param2 $param3 $param4 $param5 $param6 >> tps-log/transfer-to.txt 
    echo "transfer $i"
done

echo "transfer-to-once updated"
sleep 60 

GAIA_SEED=$(kubectl get pods | grep gaia-seed | awk -F' ' '{print $1}')
for (( i=0; i < ${PRIV_KEYS_LEN}; i++ ))
do

    address=${ADDRESSES[$i]}
    echo $GAIA_SEED $address 
    ACCOUNT_NUMS[$i]=$(kubectl exec $GAIA_SEED -it --container gaia-seed -- gaiacli query account $address --trust-node | grep accountnumber | sed "s/accountnumber://g" | sed 's/ //g' | sed "s/\r//g" | sed "s/\n//g")
    echo "ACCOUNT_NUM[$i]" ${ACCOUNT_NUMS[$i]}
done

#sleep 60
rm -rf tps-log/transfer-to-log*

for (( i=0; i < ${PRIV_KEYS_LEN}; i++ ))
do
    j=$((i % $TARGETS_LEN))
    param1=${TARGETS[$j]}
    param2=${PRIV_KEYS[$i]}
    param3=${ACCOUNT_NUMS[$i]}
    ./transfer-to.py $param1 $param2 $param3 >> tps-log/transfer-to-log$i.txt & 
done
