# Resources used: w.geeksforgeeks.org/encrypt-and-decrypt-files-using-python/
# https://www.geeksforgeeks.org/python-tkinter-messagebox-widget/
import os
import tkinter as tk
from tkinter import messagebox
from cryptography.fernet import Fernet
# Pop-up message to be displayed 
root = tk.Tk()
root.withdraw()
# Grabs the absolute path of this script
script_directory = os.path.dirname(os.path.abspath(__file__))
# Change file(s) you want to decrypt here - it will grab the absolute path of those as well
filename = "file.txt"
file_path = os.path.join(script_directory, filename)
# Opens up that filekey.key file to grab the key
with open('filekey.key', 'rb') as filekey:
    key = filekey.read()
fernet = Fernet(key)
# Reads and throws the encrypted file contents into a variable
with open(file_path, 'rb') as enc_file:
    encrypted = enc_file.read()
# This line decrypts the contents of the file using that key
decrypted = fernet.decrypt(encrypted)
# Writes the decrypted content back to the file and displays a message
with open(file_path, 'wb') as dec_file:
    dec_file.write(decrypted)
    messagebox.showinfo("ALERT", "Sigh ok here's your files back")
