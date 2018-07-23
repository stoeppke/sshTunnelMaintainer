#! /bin/bash
yes n | ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa -q && echo "maintainer produced keypair"
cat ~/.ssh/id_rsa.pub >> MaintainersKey && echo "Maintainers Key written to external avavible file /MaintainersKey"
docker-compose up --build && echo "ssh and http Server started"
# use this to connect to the client
# ssh root@ssh_server -p 1234