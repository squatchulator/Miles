from cryptography.fernet import Fernet
import os

def generate_key(password):
    return Fernet.generate_key()

def encrypt_file(file_path, key):
    with open(file_path, 'rb') as f:
        data = f.read()
    
    fernet = Fernet(key)
    encrypted_data = fernet.encrypt(data)
    
    with open(file_path + '.encrypted', 'wb') as f:
        f.write(encrypted_data)
    
    os.remove(file_path)

def decrypt_file(file_path, key):
    with open(file_path, 'rb') as f:
        data = f.read()
    
    fernet = Fernet(key)
    decrypted_data = fernet.decrypt(data)
    
    with open(file_path[:-10], 'wb') as f:
        f.write(decrypted_data)
    
    os.remove(file_path)

def main():
    password = input("Enter password: ")
    key = generate_key(password.encode())
    
    action = input("Enter 'encrypt' or 'decrypt' to choose action: ")
    if action.lower() == 'encrypt':
        files = [f for f in os.listdir('.') if os.path.isfile(f)]
        for file in files:
            if file.endswith('.encrypted'):
                continue
            encrypt_file(file, key)
        print("Files encrypted successfully.")
    elif action.lower() == 'decrypt':
        files = [f for f in os.listdir('.') if os.path.isfile(f)]
        for file in files:
            if not file.endswith('.encrypted'):
                continue
            decrypt_file(file, key)
        print("Files decrypted successfully.")
    else:
        print("Invalid action.")

if __name__ == "__main__":
    main()
