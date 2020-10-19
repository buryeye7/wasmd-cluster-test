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

function add_key() {
    expect -c "
    set timeout 3
    spawn wasmcli keys add $1
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

function gentx() {
    expect -c "
    set timeout 3
    spawn wasmd gentx --name $1
    expect "passphrase:"
    send \"$PW\\r\"
    expect "passphrase:"
    send \"$PW\\r\"
    expect "passphrase:"
    send \"$PW\\r\"
    expect eof
    "
}

ps -ef | grep wasmd > /tmp/wasmd.txt

while read line
do
    if [[ $line == *"auto"* ]];then
        continue 
    fi
    target=$(echo $line |  awk -F' ' '{print $2}')
    echo $target
    kill -9 $target
done < /tmp/wasmd.txt

rm -rf $HOME/.wasmd
rm -rf $HOME/.wasmcli

wasmcli config chain-id testnet
wasmcli config trust-node true
wasmcli config node http://localhost:26657
wasmcli config output json

# init node
wasmd init testnet --chain-id testnet 

sed -i -r 's/minimum-gas-prices = ""/minimum-gas-prices = "0.025ucosm"/' $HOME/.wasmd/config/app.toml
sed -i "s/prometheus = false/prometheus = true/g" $HOME/.wasmd/config/config.toml


add_key_first node
for i in {1..10}
do
	add_key node$i
done

node=$(show_key node)
wasmd add-genesis-account $node 1000000000stake,100000000000000000000ucosm
#for i in {1..10}
#do
#    node=$(show_key node$i)
#    wasmd add-genesis-account $node 1000000000stake,100000000000000000000ucosm
#done

gentx node

wasmd collect-gentxs
wasmd validate-genesis

#wasmd start
