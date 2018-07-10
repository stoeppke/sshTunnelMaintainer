#! /bin/sh

echo "Hello from client"
# autossh -M 20000 -f -N your_public_server -R 1234:localhost:22 -C
# ToDo: start backward ssh connect <- allow specif pubkey to access
# sshpass -p "password" autossh -o StrictHostKeyChecking=no -M 0 app@ssh_server

ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa -q
sshpass -p "password" ssh-copy-id -o StrictHostKeyChecking=no app@ssh_server
autossh -M 0 app@ssh_server