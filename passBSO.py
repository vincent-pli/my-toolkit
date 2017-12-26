import sys
import telnetlib
import socket
import os

HOSTS = ("192.168.3.11")
user = "foo@gmail.com"
password = "xxxxxx"
time_out_sec = 60
user_input_symbol = ["Username: ", "login: "]
quite_symbol = ["Login incorrect", "BSO Authentication Successful "]
for item in HOSTS:
    try:
        tn = telnetlib.Telnet(item)
        tn.set_debuglevel(9)
        #tn.read_until("Username: ")
        tn.expect(user_input_symbol, time_out_sec)
        tn.write(user + "\n")
        if password:
            tn.read_until("Password: ")
            tn.write(password + "\n")

        tn.expect(quite_symbol, time_out_sec)
        tn.write("exit\n")
        tn.close()
    except socket.error, e:
        print item + " BSO has been passed"

