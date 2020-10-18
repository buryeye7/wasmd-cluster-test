#!/usr/bin/python3

import sys
import requests
import json
from cosmospy import Transaction

#privkey="ef10157a847bf6d99d25bc1c4b9c99c3230538ceaa918703a6fe50dd7c502071"
#host="http://localhost:1317/txs"
host="http://" + "a740f5476f98011eaaf0006497dff3ad-1954321025.ap-northeast-1.elb.amazonaws.com" + ":1317/txs"
res=requests.get('/'.join([host, "86C6CDA184B0D781B16AB5E9CAB51B1E72A11CE1D0F07ED4A2D123D9158EDE1F"]))
res = json.loads(res.text)
print(res)
#res=json.loads(res)
#print(res.txhash)
