#!/bin/bash
# to be run in server at first server startup

if [ -s  /ssh_server_pass ]
then
    PASSWORD=$(cat /ssh_server_pass) && echo "Password $PASSWORD taken from /ssh_server_pass (dolus eventualis)"
else
    PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n1) && echo $PASSWORD > /ssh_server_pass && echo "Password $PASSWORD written to /ssh_server_pass (dolus eventualis)"
fi

# Switch comments if client has no password but still needs to connect. Look in InitialRun.sshd_config too
echo "restricted_user:$PASSWORD" | chpasswd -c SHA512
# passwd -d restricted_user

cat /MaintainersKey >> ~/.ssh/authorized_keys

exit