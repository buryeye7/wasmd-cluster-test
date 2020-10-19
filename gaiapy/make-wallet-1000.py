#!/usr/bin/python3

import sys
sys.path.append("/home/ubuntu/workspace/cosmospy")

from cosmospy import generate_wallet

for i in range(50): 
    wallet = generate_wallet()
    dataList=[]
    dataList.append(":".join(["\"private_key\"","\"" + wallet["private_key"] + "\""]))
    dataList.append(":".join(["\"public_key\"","\"" + wallet["public_key"] + "\""]))
    dataList.append(":".join(["\"address\"","\"" + wallet["address"] + "\""]))
    data = "{" + ",".join(dataList) + "}"
    print(data)
