#!/usr/bin/python3

import sys
import requests
import json
import time
import datetime
from cosmospy import Transaction
from cosmospy import WasmTransaction

#privkey="ef10157a847bf6d99d25bc1c4b9c99c3230538ceaa918703a6fe50dd7c502071"
#host="http://localhost:1317/txs"
host="http://" + sys.argv[1] + ":1317/txs"
privkey=sys.argv[2]
account_num=sys.argv[3]
contract=sys.argv[4]
print("host " + host)
print("privkey " + privkey)

diffList=[]
fd=open("./diffs/diff_" + privkey +".txt","w")

i=0
#for i in range(10000):
while i < 1000000:
        print("count", i)
        print("trigger time", datetime.datetime.now())
        tx = WasmTransaction(
                privkey=privkey,
                account_num=account_num,
                sequence=i,
                fee=10000,
                fee_denom='ucosm',
                gas=200000,
                memo="",
                chain_id="testnet",
                sync_mode="sync"
            )
        amount = (i+1)%100 + 1
        try:
            tx.add_wasm_execute(contract=contract, amount=amount, denom='ucosm') 
            pushable_tx=tx.get_pushable()
            #print(pushable_tx)
            headers = {'Content-Type': 'application/json; charset=utf-8'}
            startTime = datetime.datetime.now().timestamp()
            res=requests.post(host, headers=headers, data=pushable_tx)
            endTime = datetime.datetime.now().timestamp()
            diff = endTime - startTime
            diffList.append(str(diff) + "\n")
            #res=requests.post(host, data=pushable_tx)
            print(res.status_code)
            print(res.text)
            if not "code" in res.text:
                i += 1
        except:
            print("exception happened", sys.exc_info()[0])
        #time.sleep(1)
        
for diff in diffList:
    fd.write(diff)
fd.close()
