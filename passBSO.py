import sys
import telnetlib

HOSTS = ("192.168.1.139")
user = "foo"
password = "letmein"
user_input_symbol=("Username: ", "login: ")

for item in HOSTS:
    tn = telnetlib.Telnet(item)
    tn.set_debuglevel(9)
    tn.expect(user_input_symbol)
    tn.write(user + "\n")
    if password:
        tn.read_until("Password: ")
        tn.write(password + "\n")

    #tn.write("ls\n")
    tn.write("exit\n")
    print tn.read_all()
