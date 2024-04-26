import csv
import subprocess

def add_account_to_csv(csv_file, account_info):
    with open(csv_file, 'a', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(account_info)

def execute_powershell_script(script_path):
    subprocess.run(["powershell", "-File", script_path])

def main():
    csv_file = 'user.list.Generator.csv'
    powershell_script = 'config.ps1'  # Replace 'your_script.ps1' with your actual PowerShell script path

    print("Enter account information:")
    name = input("Name: ")
    pf_name = input("pfName: ")
    l_name = input("lName: ")
    role = input("Role: ")
    email = input("Email: ")

    account_info = [name, pf_name, l_name, role, email]

    add_account_to_csv(csv_file, account_info)
    print("Account added successfully!")

    execute_powershell_script(powershell_script)

if __name__ == "__main__":
    main()
