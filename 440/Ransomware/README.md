Hello!

This project is a proof of concept for a class at Champlain College called SEC-440 in my time studying Cybersecurity and Computer Networking.
It is just that - a proof of concept. It has the capability of being used maliciously, so I implore those who see this to only test this on 
their own environments, in a context where you will not damage your own systems or others. 

Usage:
In order to use this project, pull the repo https://github.com/squatchulator/Miles/440/Ransomware. It will contain 4 files for you to demo 
this project with. Before starting, you will need to install a few things:
```
sudo apt install python3
sudo apt install python3-tk
sudo apt install python3-cryptography
```
Once these libraries are installed and Python is functional, run `sudo python3 <path to repo>/encrypt.py` to execute the encryption of the test file.
To decrypt, simply do the same but replacing the file with `decrypt.py`. 
To test the mitigation script, open a second terminal and run the `ransomwaren't.py` script to create automated backups with verified file hashes.

For more info on usage and development, view my Tech Journal here: https://github.com/squatchulator/Tech-Journal/wiki/Final-Project%3A-Ransomware---Mitigation
