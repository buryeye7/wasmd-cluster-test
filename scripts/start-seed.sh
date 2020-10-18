#!/bin/bash

COUCHDB="http://admin:admin@couchdb-app-svc:5984"
PW="12345678"

mkdir -p $HOME/.nodef
mkdir -p $HOME/.clif

cp -rf $GOPATH/src/new-friday-cluster-test/config/nodef-config/* $HOME/.nodef
cp -rf $GOPATH/src/new-friday-cluster-test/config/clif-config/* $HOME/.clif
sed -i "s/prometheus = false/prometheus = true/g" $HOME/.nodef/config/config.toml
sed -i "s/size = 5000/size = 10000/g" $HOME/.nodef/config/config.toml

clif config chain-id testnet

ps -ef | grep nodef | while read line
do
    if [[ $line == *"nodef"* ]];then
        target=$(echo $line |  awk -F' ' '{print $2}')
        kill -9 $target
    fi
done

NODE_ID=$(nodef tendermint show-node-id)
IP_ADDRESS=$(hostname -I)
IP_ADDRESS=$(echo $IP_ADDRESS)

curl -X PUT $COUCHDB/seed-info/seed-info -d "{\"target\":\"${NODE_ID}@${IP_ADDRESS}:26656\"}"

for i in $(seq 1 $WALLET_CNT)
do
    wallet_address=$(clif keys show node$i -a)
    echo $wallet_address
    curl -X PUT $COUCHDB/seed-wallet-info/$wallet_address -d "{\"wallet_alias\":\"node$i\"}"
done

nodef start 2>&1 > /tmp/nodef.log &
sleep 20
clif rest-server --chain-id=testnet --laddr tcp://0.0.0.0:1317 2>&1 > /tmp/clif.log 
