# sshTunnelMaintainer

Easy and stable access to a friends Pi (or whatever) via ssh through foreign NAT and/or Firewall. Therefore build a stable ssh remote tunnel the pi to your dockerized ssh server over which you can ssh to the pi. But you'll need a ddns or dns address where you are reachable.

## Security

### Root shell on client side

The client will write the given `MaintainersKey` into his `/root/.ssh/authorized_keys` (find this in `PiClientRun.sh` file: `autossh -M 0 ssh_server 'cat /MaintainersKey' >> /root/.ssh/authorized_keys`, line 60). 

This will grant you **root access to your** friends device!!! In your friends interest watch out which keys are in the `MaintainersKey` file and **secure your ssh privat key**.!!!

### Accessing server and probable consequences

The `authorized_keys_ToConnectToServerRestricted` file holds pubkeys of clients who are allowed to ssh to your ssh-server using the **restricted_user** account. 
The **restricted_user** account should *(I'm not 100% shure)* only be able to accept ssh connections and forward ports. Nothing else; no evil I/O tasks, no networkstuff... . The possibilities of this user could escalate so it can damage something. For your own peace look  into `ssh_server.dockerfile`, `sshd_config` and `InitialRun.sh` where the accounts granted rights are set and edited.

### access via Password

The servers *restricted_user* account can be accessed using the Password from the `ssh_server_pass` file, where only one line is allowed and it must exist on the first server startup. The file can stay empty (but don't delete it); then the the server will write the password into this file.

Because this password only grants access to the *restricted_user* account, it's not very sensible and you can change it through a server restart without loosing the connection to your friends pi (`docker-compose down; docker-compose up`).

The password can be found in the compose log too: `docker-compose logs ssh_server | grep "dolus eventualis"`

----------

## Stability

To enable a stable connection, on client side [autossh](http://www.harding.motd.ca/autossh/) is used and it's started as a **systemd service** using the config in the `autossh-jump-rtunnel.service` file.

A server restart is no problem, just secure the content of the `authorized_keys_ToConnectToServerRestricted` file which holds the clients keys to access your server. A Client restart should be no problem: it starts autossh as service with every system start and tries to connect in some repeating time intervals (I don't care, it works, look here: [autossh README](http://www.harding.motd.ca/autossh/README.txt)). Details are setup in the `autossh-jump-rtunnel.service` service-File. 

## Easy

Your friend only has to enter one line, following of domainname-port in one line and password in a third, all asked by a script. After a server and/or client restart the connection will be re-established after a short time. Only your domainname and port forwarding should not change to keep the connection.

Only outgoing traffic to your server on your ports must be possible, then you can establish your own ssh-tunnel to the clients device. Your friend can move his machine to wherever he wants, it will reconnect (if the one outgoing port you selected is not blocked like with FritzBox guest connections; check free ports with `nmap portquiz.net`).

## How it works

### General

The ssh-http-server combination uses three ports, two exposed to the internet which are used to:

* (public) establish **ssh connections** from the clients to your server (here 6523, but free choice)
* (public) supply your friend with a script from a **http server** (*`curl http://YourDomain.com:6522`, again your free choice*)
* (not public) ssh -R tunnel endpoint on your side (here 8717, free choice).

Don't forget to **forward the public ports** on your router. My OpenWrt setup looks like this. More to find here [OpenWrt Firewall redirect](https://openwrt.org/docs/guide-user/firewall/firewall_configuration#redirects)

```

config redirect
	option target 'DNAT'
	option src 'wan'
	option dest 'lan'
	option proto 'tcp'
	option src_dport '****'
	option dest_ip '192.168.0.150'
	option dest_port '6523'
	option name 'docker ssh_server on PI'

config redirect
	option target 'DNAT'
	option src 'wan'
	option dest 'lan'
	option proto 'tcp'
	option src_dport '****'
	option dest_ip '192.168.0.150'
	option dest_port '6522'
	option name 'docker ssh_server supplier on PI'

```

### Cookbook

To do in given order:

* **set ports** you desired in the `docker-compose.yml` file
  * Line 11 (ssh_server ssh port): give this number to your friend later && forward to internet
  * Line 31 (script_supplyer http): use this port in the *supply your friend* part && forward to internet
* **forward above ports** on your router, see my OpenWrt setup above
* write your **ssh-pub key into `MaintainersKey`** file
  * `cd sshTunnelMaintainer/ && cat ~/.ssh/id_rsa.pub > MaintainersKey`
* **start server** using docker-compose with build option *(cd into sshTunnelMaintainer before)*
  * `docker-compose up --build`
* **supply your friend** with this one line so he can execute it. Insert your domainname and the above set http-server port (default 6522)
  * `sudo bash -c "$(curl -fsSL YourDomain.com:6522/PiClientRun.sh)"`
* He will be asked for your domainname and ssh_server port number (Line 11, default 6523), in one line, space separated. In a new line for the password
  * Password - password can be found in the `ssh_server_pass` file or via executing `docker-compose logs ssh_server | grep "dolus eventualis"`
  * give him something like this:
    * `YourDomain.com 6523`
    * `bCFKgBVFMlSirPm`
* Connect to your friends Pi using the not public available port of your docker ssh_server (8717 default). If the docker-instance is not running on premise, use a ssh-tunnel to access this port
  * ssh-tunnel to where docker is running: `ssh -L 8717:localhost:8717 -N yourUser@yourHostingServer`
  * access your friends pi: `ssh root@192.168.0.150 -p 8717` (no password should be asked, you're using key authentication).
* Don't destroy too much, think about using docker there.

## Local testing

The `vagrantfile` allows you to test this setup with a local Raspberian VM. To use it, [install vagrant](https://www.vagrantup.com/docs/installation/) , cd into sshTunnelMaintainer,run `vagrant up` and enter this vm using `vagrant ssh`. It uses something like a lot of space, so `vagrant destroy` when you're done (everything inside the one folder; it is all using the vagrantfile).

<!-- You could use another docker container. Something like `docker run --rm -ti --network="ssh-server_default" ubuntu` and in there you need to install stuff before trying out `apt update && apt install openssh-client curl -y`. Then cook by the books last instuction (you're already root, no sudo) : `bash -c "$(curl -s script_supplyer:80/PiClientRun.sh)"` -->
