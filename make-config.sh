#!/bin/bash

rm -rf config

mkdir -p config/wasmd-config
mkdir -p config/wasmcli-config

cp -rf $HOME/.wasmd/* config/wasmd-config/
cp -rf $HOME/.wasmcli/* config/wasmcli-config/
