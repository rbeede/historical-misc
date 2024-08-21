import binascii
import random
import sys
import yubico


try:
    yubikey = yubico.find_yubikey(debug=False)
    print("Version: {}".format(yubikey.version()))
    print(f"Status: {yubikey.status()}")
except yubico.yubico_exception.YubicoError as e:
    print("ERROR: {}".format(e.reason))
    sys.exit(1)
    

Cfg = yubikey.init_config(update=True)

while True:
    random_code = random.randbytes(6)
    Cfg.unlock_key(random_code)
    Cfg.access_key(random_code)

    try:
        yubikey.write_config(Cfg, slot=1)
        
        print('SUCCESS WITH')
        print(binascii.hexlify(random_code))
        sys.exit(0)
    except yubico.yubico_exception.YubicoError as e:
        print("ERROR: {}".format(e.reason))
        print(binascii.hexlify(random_code))