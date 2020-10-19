import hashlib

import bech32
import ecdsa

from cosmospy.typing import Wallet

from mnemonic import Mnemonic
from cosmospy.bip_to_mnemonic import mnemonic_to_key

#friday
#def generate_wallet() -> Wallet:
#    privkey = ecdsa.SigningKey.generate(curve=ecdsa.SECP256k1).to_string().hex()
#    pubkey = privkey_to_pubkey(privkey)
#    address = pubkey_to_address(pubkey)
#    return {"private_key": privkey, "public_key": pubkey, "address": address}

def generate_wallet():
    m = Mnemonic("english")
    mnemonic = m.generate(strength=256)
    #privkey, pubkey = bip_to_mnemonic.mnemonic_to_key(mnemonic)
    privkey, pubkey = mnemonic_to_key(mnemonic)
    address = pubkey_to_address(pubkey)
    return {"private_key": privkey, "public_key": pubkey, "address": address, "mnemonic": mnemonic}

def privkey_to_pubkey(privkey: str) -> str:
    privkey_obj = ecdsa.SigningKey.from_string(bytes.fromhex(privkey), curve=ecdsa.SECP256k1)
    pubkey_obj = privkey_obj.get_verifying_key()
    return pubkey_obj.to_string("compressed").hex()


def pubkey_to_address(pubkey: str) -> str:
    pubkey_bytes = bytes.fromhex(pubkey)
    s = hashlib.new("sha256", pubkey_bytes).digest()
    r = hashlib.new("ripemd160", s).digest()
    #return bech32.bech32_encode("cosmos", bech32.convertbits(r, 8, 5))
    #friday
    return bech32.bech32_encode("friday", bech32.convertbits(r, 8, 5))


def privkey_to_address(privkey: str) -> str:
    pubkey = privkey_to_pubkey(privkey)
    return pubkey_to_address(pubkey)
