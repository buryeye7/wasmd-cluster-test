#!/usr/bin/python3

import sys
import requests
import json
import time
import datetime
from cosmospy import Transaction

#privkey="ef10157a847bf6d99d25bc1c4b9c99c3230538ceaa918703a6fe50dd7c502071"
#host="http://localhost:1317/txs"
host="http://" + sys.argv[1] + ":1317/txs"
privkey=sys.argv[2]
account_num=sys.argv[3]
sequence=sys.argv[4]
amount=sys.argv[5]
dest=sys.argv[6]
print("host " + host)
print("privkey " + privkey)
print("account_num " + account_num)
print("sequence " + sequence)
print("amount " + amount)
print("dest " + dest)

tx = Transaction(
        privkey=privkey,
        account_num=account_num,
        sequence=sequence,
        fee=1000,
        gas=70000,
        memo="",
        chain_id="testnet",
        sync_mode="sync"
    )
try:
    tx.add_transfer(recipient=dest, amount=amount) 
    pushable_tx=tx.get_pushable()
    #print(pushable_tx)
    headers = {'Content-Type': 'application/json; charset=utf-8'}
    fd=open("./diffs/diff.txt", "a")
    startTime = datetime.datetime.now().timestamp()
    res=requests.post(host, headers=headers, data=pushable_tx)
    endTime = datetime.datetime.now().timestamp()
    diff = endTime - startTime
    fd.write(str(diff) + "\n")
    fd.close()
    #res=requests.post(host, data=pushable_tx)
    #print(res.status_code)
    #print(res.text)
except:
    print("exception happened", sys.exc_info()[0])
