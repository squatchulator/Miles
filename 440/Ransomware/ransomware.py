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

def encrypt_folder(folder_path, key):
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            file_path = os.path.join(root, file)
            encrypt_file(file_path, key)

def decrypt_folder(folder_path, key):
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            if file.endswith('.encrypted'):
                file_path = os.path.join(root, file)
                decrypt_file(file_path, key)

def main():
    password = input("Enter password: ")
    key = generate_key(password.encode())
    
    action = input("Enter 'encrypt' or 'decrypt' to choose action: ")
    if action.lower() == 'encrypt':
        encrypt_folder('.', key)
        print("Files and folders encrypted successfully.")
    elif action.lower() == 'decrypt':
        decrypt_folder('.', key)
        print("Files and folders decrypted successfully.")
    else:
        print("Invalid action.")

if __name__ == "__main__":
    main()
