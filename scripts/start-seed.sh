#!/bin/bash

COUCHDB="http://admin:admin@couchdb-app-svc:5984"
PW="12345678"

mkdir -p $HOME/.wasmd
mkdir -p $HOME/.wasmcli

cp -rf $GOPATH/src/wasmd-cluster-test/config/wasmd-config/* $HOME/.wasmd
cp -rf $GOPATH/src/wasmd-cluster-test/config/wasmcli-config/* $HOME/.wasmcli
#sed -i "s/prometheus = false/prometheus = true/g" $HOME/.wasmd/config/config.toml
sed -i "s/size = 5000/size = 10000/g" $HOME/.wasmd/config/config.toml

wasmcli config chain-id testnet

ps -ef | grep wasmd > /tmp/wasmd.txt

while read line
do
    if [[ $line == *"auto"* ]];then
        continue
    fi
    target=$(echo $line | awk -F' ' '{print $2}')
    kill -9 $target
done < /tmp/wasmd.txt

NODE_ID=$(wasmd tendermint show-node-id)
IP_ADDRESS=$(hostname -I)
IP_ADDRESS=$(echo $IP_ADDRESS)

curl -X PUT $COUCHDB/seed-info/seed-info -d "{\"target\":\"${NODE_ID}@${IP_ADDRESS}:26656\"}"

for i in $(seq 1 $WALLET_CNT)
do
    wallet_address=$(wasmcli keys show node$i -a)
    echo $wallet_address
    curl -X PUT $COUCHDB/seed-wallet-info/$wallet_address -d "{\"wallet_alias\":\"node$i\"}"
done

wasmd start 2>&1 > /tmp/wasmd.log &
sleep 20
wasmcli rest-server --chain-id=testnet --laddr tcp://0.0.0.0:1317 2>&1 > /tmp/wasmcli.log 
