import os
import shutil
import hashlib
import time

# Set the path of where this script is being executed from
script_directory = os.path.dirname(os.path.abspath(__file__))
# Target file(s) go here, it will grab the absolute path of that as well
filename = "file.txt"
file_path = os.path.join(script_directory, filename)
backup_path = file_path + ".bac"
print("This script will check the file integrity of", filename, "every 5 seconds.")
print("If the file has changed at all, backups will cease and an alert will appear.")
# Create an initial backup of the file
def create_backup():
    shutil.copyfile(file_path, backup_path)

# Calculate the hash of a file to make sure it hasn't changed at all
def calculate_file_hash(file_path):
    hasher = hashlib.sha256()
    # Open the file path and make sure the hash is exact
    with open(file_path, 'rb') as file:
        while True:
            chunk = file.read(65536)  # 64 KB chunks
            if not chunk:
                break
            hasher.update(chunk)
    return hasher.hexdigest()

# Calculate the initial hash of the file
initial_hash = calculate_file_hash(file_path)

try:
    # Infinite loop for persistent monitoring
    while True:
        # Check if the file integrity has changed at all
        current_hash = calculate_file_hash(file_path)
        # If changes are found then stop creating backups to preserve most recent
        if current_hash != initial_hash:
            print("File integrity changed. Backup process stopped.")
            break
        
        # Create a backup of the file
        create_backup()
        
        # Wait for 5 seconds before creating the next backup
        time.sleep(5)
except KeyboardInterrupt:
    print("Backup process interrupted by user.")