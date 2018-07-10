# sshTunnelMaintainer
The aim is to set up a secure ssh-server in a container in a controled ddns accassable network start a ssh tunnel to it. The clinet authorizes a public ssh key from the maintaining person. The pub key is stored on the docker instance hosting the ssh-server. 

# Help develop
How to test the current setup (not yet for deployment, just dev):
- [docker & docker-composed is installed](https://docs.docker.com/compose/install/)
- 
```bash
docker-compose up --build
```