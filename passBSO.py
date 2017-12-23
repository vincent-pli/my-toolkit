import sys
import telnetlib
import socket

HOSTS = ("192.168.3.111")
user = "foo@163.com"
password = "xxxxxx"
user_input_symbol=["Username: ", "login: "]
for item in HOSTS:
    try:
        tn = telnetlib.Telnet(item)
        tn.set_debuglevel(9)
        #tn.read_until("Username: ")
        tn.expect(user_input_symbol)
        tn.write(user + "\n")
        if password:
            tn.read_until("Password: ")
            tn.write(password + "\n")

        #tn.write("ls\n")
        tn.write("exit\n")
        print tn.read_all()
    except socket.error, e:
        print item + " BSO has been passed"
