# Greenhouse Ivy - Automations & Utils
## Ansible

### Configuration

To configure the project, we have created the folder `/greenhouse` that will contain this repository with all devops configs.

See below the three of folders:

```
/greenhouse/
└── ivy-automation
    ├── ansible
    │   ├── ansible.cfg
    │   ├── ansible_vault_password
    │   ├── inventory
    │   │   ├── computers
    │   │   └── host_vars
    │   │       ├── debian.yml
    │   │       ├── rpi.yml
    │   │       ├── vault.yml (only on the machine. Ignored on repo.)
    │   │       └── w3070.yml
    │   ├── playbooks
    │   │   ├── ping.yml
    │   │   └── variable_checker.yml
    │   └── ssh
    │       ├── id_ansible
    │       └── id_ansible.pub
    ├── LICENSE
    ├── profiles
    │   └── ...
    └── README.md

```

#### Inventory

File that will contain the list of IP, hostnames or DNS names that Ansible will manage. On [ansible.cfg](./ansible/ansible.cfg) file, we have added the variable `inventory` that contains the path for the main inventory that we will use.

```yml
all:
    children:
        windows:
            hosts:
                w3070:
        linux:
            hosts:
                rpi:
                debian:
        vbox:
            hosts:
                debian:
        greenhouse:
            hosts:
                w3070:
                rpi:
                debian:
```

#### Connectivity Check

Let first add the next command to ensure that ansible is able to reach all given machines in `/ansible/config/inventory` file.

```bash
$ ansible all --key-file /path/to/ssh/key -i /path/to/inventory/file -m ping --limit {host-name}
# ex
$ ansible all -i inventory.yaml -m win_ping --limit w3070
$ ansible all -i inventory.yaml -m ping --limit rpi
```

#### WinRm - Setting Up a Windows Host

Using as reference [Official Ansible Docs for Windows Setup][Official Ansible Docs - Windows Setup]

##### Upgrade of Powershell

```powershell
# Check versions available
> winget search Microsoft.PowerShell
# Install
> winget install --id Microsoft.Powershell --source winget
> winget install --id Microsoft.Powershell.Preview --source winget
```

### SSH Key Generation

To check the current Keys check folder `\home\{user}\.ssh`. Inside should be located the file `known_hosts` plus the keys generated.

```bash
# To generate a key, execute the next command:
$ ssh-keygen -t ed25519 -C Ansible
# To copy the ssh key to a Server
$ ssh-copy-id -i {oath of public ssh key. ie: /home/gh/.ssh/id.pub} {IP of the Server}
```

### Vaults

To make the setup, we created the file `inventory/host_vars/vault.yml` and added all credentials to make reference to them later on playbooks.

Once created, just do `ansible-vault encrypt`.

```bash
$ ansible-vault encrypt --vault-password-file ansible_vault_password inventory/host_vars/vault.yml
$ ansible-vault view --vault-password-file ansible_vault_password inventory/host_vars/vault.yml  
$ ansible-vault edit --vault-password-file ansible_vault_password inventory/host_vars/vault.yml
```

On [ansible.cfg](./ansible/ansible.cfg) file, we have added the variable `vault_password_file` that contains the password used to encrypt in vault. So it won't require to use the flag `--vault-password-file ansible_vault_password` anymore.

### References

[Official Docs - Debian installation]: https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html#installing-ansible-on-debian 	"Debian Installation"
[Youtube - Learn Linux TV - Getting Started with Ansible]: https://www.youtube.com/playlist?list=PLT98CRl2KxKEUHie1m24-wkyHpEsa4Y70 "Learn Linux TV - Getting Started with Ansible"
[Reference - Jeff Geerling]: https://www.jeffgeerling.com/blog	"Jeff Geerling"
[Reference - Percy Grunwald]: https://www.percygrunwald.com/ "Percy Grunwald"
[Official Ansible Docs - Windows Setup]: https://docs.ansible.com/ansible/latest//os_guide/windows_setup.html#windows-setup "Windows Setup"

## Profiles
The `.bashrc` file includes few tiny functions that would help and make environments more comfortable.

### Required Environment Variables

| Variable  Name              | Description                                                  | Example                           |
| --------------------------- | ------------------------------------------------------------ | --------------------------------- |
| `BASE_GREENHOUSE_WORKSPACE` | Main folder where the repositories of Greenhouse are placed. | /c/Users/mike/Documents/Workspace |

## Quick summary of System CTL commands:

Explanation of Commands:

- `systemctl start <service>`: Starts the service immediately (in this case, SSH).
- `systemctl enable <service>`: Enables the service to start automatically at system boot.
- `systemctl status <service>`: Shows the current status of the service (running, stopped, etc.).
- `systemctl is-enabled <service>`: Checks if the service is enabled to start on boot.
- `systemctl stop <service>`: Stops the service immediately.
- `systemctl disable <service>`: Disables the service from starting at boot.

## Docker

Starting with the design of the infrastructure for the application.

*  [docker-compose.yml](docker/docker-compose.yml): [Nginx][nginx] + [Wireguard][wireguard]([wg-easy][ez_wg])  images.

### Development

To wake up the [docker-compose.dev.yml](docker/docker-compose.dev.yml), for the VPN you will have to do some additional changes on the machine.

> First of all, log in on your router, and apply the port forwarding for the machine that you will use as a host.
> The list of ports would be listed on the table of below.
>
> Each router has their own way of configuring this, so time to use Google.

The ports at the moment to be opened & forwarded are:

| Application |    Port     |
| :---------: | :---------: |
|  Wireguard  | 51820-51821 |
| Main Nginx  |     80      |

#### Firewall on Windows

Search and open **Windows Defender Firewall**. Go to **Advanced settings**

![windows-defender-firewall](./README.assets/windows-defender-firewall.png)

Go to **Inbound Rules** and **New Rule...** as we are allowing external connections.

![windows-inbound](./README.assets/windows-defender-firewall-inbound.png)

Click on **Port** and add the list of ports provided above + click on **TCP**.

![windows-inbound-port](./README.assets/windows-defender-firewall-inbound-port.png)

![windows-inbound-port-01](./README.assets/windows-defender-firewall-inbound-port-01.png)

Let's go at the moment with Allow the connection option.

![windows-inbound-port-02](./README.assets/windows-defender-firewall-inbound-port-02.png)

![windows-inbound-port-03](./README.assets/windows-defender-firewall-inbound-port-03.png)

Once completed, you will see the new rule on the Inbound Rules window. In this sample, **Greenhouse Ports**.

![windows-inbound-port-04](./README.assets/windows-defender-firewall-inbound-port-04.png)

#### Firewall on Mac

Open the terminal and modify the next file

``````bash
> sudo nano /etc/pf.conf
``````

**For each** port that you want to open, add the next line:

``````bash
pass in proto tcp from any to any port [PORT]
``````

The next lines would be use to activate/deactivate the rule:

``````bash
> sudo pfctl -f /etc/pf.conf
# Activate
> sudo pfctl -e
# Deactivate
> sudo pfctl -d
``````

To test if it is working or not:

``````bash
> sudo lsof -i :[PORT]

# The expected response should something similar to this:

> sudo lsof -i :51820
COMMAND    PID      USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
com.docke 3836   usename  200u  IPv6 0x0000000000000001      0t0  UDP *:51820
> sudo lsof -i :51821
COMMAND    PID      USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
com.docke 3836   usename  199u  IPv6 0x0000000000000001      0t0  TCP *:51821 (LISTEN)
``````

#### How to Forward traffic from [NoIp](https://www.noip.com/) to the computer

The way how the Internet provider maintain our IP can be different. They can update our IP when we restart the router or in any moment. 

There are lot of webages that can provide this info ([ipinfo.io](https://ipinfo.io/what-is-my-ip), [ipaddress.my](https://www.ipaddress.my/), [showmyip.com](https://www.showmyip.com/), [whatismyip.com](https://www.whatismyip.com/)...).

> Why NoIp? They offer by free one hostname which we will use to forward our traffic for, here it comes, **FREE**.

The screenshot of below shows how the NoIp hostname page looks like. Here you will see your hostname plus the IP where is aiming at the moment. When you are developing, you can, a, ping directly your public IP or b, use this domain.

![noip-hostname-howto](./README.assets/noip-hostname-howto.png)

### Docker Hub Links

+ [nginx]: https://hub.docker.com/_/nginx

+ [wireguard]: https://hub.docker.com/r/linuxserver/wireguard

+ [ez_wg]: https://hub.docker.com/r/weejewel/wg-easy

## Nice Readings

* [Software Architecture Patterns](https://dev.to/somadevtoo/9-software-architecture-patterns-for-distributed-systems-2o86)