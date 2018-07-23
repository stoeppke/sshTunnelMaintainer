#!/bin/bash

#cmd example to runt this code:
# sudo chmod +x PiClientRun.sh; sudo ./PiClientRun.sh "<password given in log of compose>" /home/vagrant/autossh-jump-rtunnel.service <your dns name> <port where to reach yout compose ssh_server ssh-deamon>
echo 
echo "This script will allow the person you got it from to gain root access to your device. Root access means that there are not limits in accessing and controling the device. Depending on the security in your local network other devices could be reached and even controled with the given root access."
echo "If you realy realy thrust this person enter now: yes"
echo -n "--> "
read -r UsersOk
#ToDo: curl everything needed from ssh_server

if [ ! $UsersOk == "yes" ]; then
    echo "no yes given. Script will stop"
    exit 0
fi

echo "Now, plese enter the given server details (watch for whitespaces)"
echo "<Serveradres> <ServerPort>"
echo -n "--> "
read -r Serveradress ServerPort
echo "ServerPass"
echo -n "--> "
read -s ServerPass
echo

# ServerPass=$1
# ServiceFile=$2
# ServiceFile=/home/vagrant/autossh-jump-rtunnel.service
# Serveradress=$3
# ServerPort=$4
SshConfigFolder=/root/.ssh/

apt-get update -yqq && apt-get install ssh openssh-server openssh-client sshpass autossh -yqq

# if [[ -f $ServiceFile && -n $ServerPass ]]; then
if [[ -n $ServerPass ]]; then
    if sshpass -p $ServerPass ssh -o StrictHostKeyChecking=no -o "UserKnownHostsFile /dev/null" -p $ServerPort restricted_user@${Serveradress} "exit"; then
        echo "password Valid"
    else
        echo "Password invalid. Ask for new one ore check input."
        echo "./script.sh <server password> <.service fiele> <server adress> <server port>"
        exit 0
    fi
else
    echo "Arguments missing"
    echo "./script.sh <server password> <.service fiele>"
    exit 0
fi

mkdir $SshConfigFolder

function SshdAllowKeyAuth {
    echo "sometimes acces via key is permitted. so something..."    
}

function keyexchange {
  ServerPass=$1
  yes n | ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa -q && echo "Local key sucsessfull generated"
  sshpass -p $ServerPass ssh-copy-id -o StrictHostKeyChecking=no ssh_server && echo "Client anounced ssh ub key on serverside to log into app account"
  autossh -M 0 ssh_server 'cat /MaintainersKey' >> /root/.ssh/authorized_keys && echo "forren given trusted keys are written to ~/.ssh/authorized_keys to acces the client"
}
function WriteToSshConfig {
    ConfigFile=${1}config
    Serveradress=$2
    ServerPort=$3
    if grep 'Host ssh_server' $ConfigFile -q; then
        echo "Config file already written"
    else
        cat >> $ConfigFile <<- EOM
Host ssh_server
    User restricted_user
    HostName ${Serveradress}
    Port ${ServerPort}
    IdentityFile /root/.ssh/id_rsa
EOM
    fi
}

WriteToSshConfig "$SshConfigFolder" "$Serveradress" "$ServerPort"

if [ ! -f /root/.ssh/id_rsa ]; then
    keyexchange "$ServerPass"
fi

systemctl start sshd
systemctl enable sshd

scp ssh_server:autossh-jump-rtunnel.service /etc/systemd/system/autossh-jump-rtunnel.service
# scp ssh_server:autossh-jump-rtunnel.service ./autossh-jump-rtunnel.service
# mv $ServiceFile /etc/systemd/system/autossh-jump-rtunnel.service
systemctl daemon-reload
systemctl start autossh-jump-rtunnel.service
systemctl enable autossh-jump-rtunnel.service

exit
