#!/bin/bash

PW="12345678"

function add_key_first() {
    expect -c "
    set timeout 3
    spawn wasmcli keys add $1
    expect "passphrase:"
    send \"$PW\\r\"
    expect "passphrase:"
    send \"$PW\\r\"
    expect eof
    "
}

function show_key() {
    res=$(expect -c "
    set timeout 3
    spawn wasmcli keys show -a $1
    expect "passphrase:"
    send \"$PW\\r\"
    expect eof
    " | sed "s/[^A-Z,a-z,0-9, ,:,\,,\-]//g")
    echo $(echo $res | awk -F' ' '{print $NF}')
}

COUCHDB="http://admin:admin@couchdb-app-svc:5984"
rm -rf $HOME/.wasmd
rm -rf $HOME/.wasmcli

ps -ef | grep wasmd > /tmp/wasmd.txt 

while read line
do
    if [[ $line == *"auto"* ]];then
        continue
    fi
    target=$(echo $line |  awk -F' ' '{print $2}')
    kill -9 $target
done < /tmp/wasmd.txt

# run execution engine grpc server
wasmd init --chain-id testnet testnet

add_key_first node

cp -f $GOPATH/src/wasmd-cluster-test/config/wasmd-config/config/genesis.json $HOME/.wasmd/config

SEED=$(curl $COUCHDB/seed-info/seed-info | jq .target)
sed -i "s/seeds = \"\"/seeds = $SEED/g" $HOME/.wasmd/config/config.toml
sed -i "s/prometheus = false/prometheus = true/g" $HOME/.wasmd/config/config.toml
sed -i "s/size = 5000/size = 10000/g" $HOME/.wasmd/config/config.toml
sed -i -r 's/minimum-gas-prices = ""/minimum-gas-prices = "0.025ucosm"/' $HOME/.wasmd/config/app.toml

WALLET_ADDRESS=$(show_key node)
NODE_PUB_KEY=$(wasmd tendermint show-validator)
NODE_ID=$(wasmd tendermint show-node-id)

curl -X PUT $COUCHDB/wallet-address/$WALLET_ADDRESS -d "{\"type\":\"full-node\",\"node_pub_key\":\"$NODE_PUB_KEY\",\"node_id\":\"$NODE_ID\", \"wallet_alias\":\"$WALLET_ALIAS\"}"

wasmd start 2>&1 > /tmp/wasmd.log &
sleep 20
wasmcli rest-server --chain-id=testnet --laddr tcp://0.0.0.0:1317 2>&1 > /tmp/wasmcli.log 

