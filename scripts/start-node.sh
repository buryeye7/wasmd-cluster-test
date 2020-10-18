#!/bin/bash

COUCHDB="http://admin:admin@couchdb-app-svc:5984"
rm -rf $HOME/.nodef
rm -rf $HOME/.clif

ps -ef | grep nodef | while read line
do
    if [[ $line == *"nodef"* ]];then
        target=$(echo $line |  awk -F' ' '{print $2}')
        kill -9 $target
    fi
done

# run execution engine grpc server
nodef init --chain-id testnet testnet

# create a wallet key
PW="12345678"

expect -c "
set timeout 3
spawn clif keys add node
expect "disk:"
send \"$PW\\r\"
expect "passphrase:"
send \"$PW\\r\"
expect eof
"

cp -f $GOPATH/src/new-friday-cluster-test/config/nodef-config/config/genesis.json $HOME/.nodef/config

SEED=$(curl $COUCHDB/seed-info/seed-info | jq .target)
sed -i "s/seeds = \"\"/seeds = $SEED/g" $HOME/.nodef/config/config.toml
sed -i "s/prometheus = false/prometheus = true/g" $HOME/.nodef/config/config.toml
sed -i "s/size = 5000/size = 10000/g" $HOME/.nodef/config/config.toml

WALLET_ADDRESS=$(clif keys show node -a)
NODE_PUB_KEY=$(nodef tendermint show-validator)
NODE_ID=$(nodef tendermint show-node-id)

curl -X PUT $COUCHDB/wallet-address/$WALLET_ADDRESS -d "{\"type\":\"full-node\",\"node_pub_key\":\"$NODE_PUB_KEY\",\"node_id\":\"$NODE_ID\", \"wallet_alias\":\"$WALLET_ALIAS\"}"

nodef start 2>&1 > /tmp/nodef.log &
sleep 20
clif rest-server --chain-id=testnet --laddr tcp://0.0.0.0:1317 2>&1 > /tmp/clif.log 

