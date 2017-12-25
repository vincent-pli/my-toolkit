#!/usr/bin/expect

set localPort "6666"
set remotIP "9.21.52.135"
set password "xxxxxx"

spawn nohup ssh -CfNg -D 127.0.0.1:${localPort} root@${remotIP}
expect "password:"
send "${password}\r"

