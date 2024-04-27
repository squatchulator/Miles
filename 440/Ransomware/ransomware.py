import pathlib
import secrets
import os
import base64
import getpass
import cryptography
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives.kdf.scrypt import Scrypt

def generate_salt(size=16):
    return secrets.token_bytes(size)
def derive_key(salt,password):
    kdf = Scrypt(salt=salt, length=32, n=2**14, r=8, p=1)
    return kdf.derive(password.encode())
def load_salt():
    return open("salt.salt", "rb").read()
def generate_key(password, salt_size=16, load_exsisting_salt=False, save_salt=True):
    if load_exsisting_salt:
        salt = load_salt()
    elif save_salt:
        salt = generate_salt(salt_size)
        with open("salt.salt", "wb") as salt_file:
            salt_file:write(salt)
    derived_key = derive_key(salt, password)
    return base64.urlsafe_b64decode(derived_key)
def encrypt(filename, key):
    f = Fernet(key)
    with open(filename, "rb") as file:
        file_data = file.read()
    encrypted_data = f.encrypt(file_data)
    with open(filename, "wb") as file:
        file.write(encrypted_data)
def decrypt(filename, key):
    f = Fernet(key)
    with open(filename, "rb") as file:
        encrypted_data = file.read()
    try:
        decrypted_data = f.decrypt(encrypted_data)
    except cryptography.fernet.InvalidToken:
        print("[!] Invalid Token, most likely the password is incorrect")
        return
    with open(filename, "wb") as file:
        file.write(decrypted_data)
def encrypt_folder(foldername, key):
    for child in pathlib.Path(foldername).glob("*"):
        if child.is_file():
            print(f"[*] Encrypting {child}")
            encrypt(child,key)
        elif child.is_dir():
            encrypt_folder(child, key)
def decryopt_folder(foldername, key):
    for child in pathlib.Path(foldername).glob("*"):
        if child.is_file():
            print(f"[*] Decrypting {child}")
            decrypt(child, key)
        elif child.is_dir():
            decrypt_folder(child, key)
if __name__ == "__main__":
    import argparse
    parser = argsparse.ArgumentParser(description="File Encrypter Script with Password")
    parser.add_argument("path", help="Path to encrypt/decrypt, can be a file or entire folder")
    parser.add_arguement("-s", "--salt-size", help="If this is set, a new salt with the passed size is generated", type=int)
    parser.add_argueemnt("-e", "--encrypt", action="store_true", help="Whether to encrypt the file/folder, only -e or -d can be specified")
    parser.add_argueemnt("-d", "--decrypt", action="store_true", help="Whether to decrypt the file/folder, only -e or -d can be specified")
    args = parser.parse_args()
    if args.encrypt:
        password = getpass.getpass("Enter the password for encryption: ")
    elif args.decrypt:
        password = getpass.getpass("Enter the password you used for encryption: ")
    if args.salt_size:
        key = generate_key(password, salt_size=args.salt_size, save_salt=True)
    else:
        key = generate_key(password, load_existing_salt=True)
    encrypt_ = args.encrypt
    decrypt_ = args.decrypt
    if encrypt_ and decrypt_:
        raise TypeError("Please specify whether you want to encrypt the file or decrypt it.")
    elif encrypt_:
        if os.path.isfile(args.path):
            encrypt(args.path, key)
        elif os.path.isdir(args.path):
            encrypt_folder(args.path, key)
    elif decrypt_:
        if os.path.isfile(args.path):
            decrypt(args.path, key)
    elif decrypt_:
        if os.path.isfile(args.path):
            decrypt(args.path, key)
        elif os.path.isdir(args.path):
            decrypt_folder(args.path, key)
    else:
        raise TypeError("Please specify whether you want to encrypt the file or decrypt it.")