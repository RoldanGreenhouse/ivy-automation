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
    │   │       ├── rpi.yml
    │   │       ├── vault.yml
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
        greenhouse:
            hosts:
                w3070:
                rpi:
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

## Configuration Over WSL 2 of Linux Distributions

### Key Differences with WSL 2 Networking

1. **WSL 2 Uses NAT by Default:**
   - WSL 2 instances run inside a virtual machine and are NATed (Network Address Translated) behind your Windows host. This means they get a private IP address (172.x.x.x), which is not directly accessible from other devices or the main network.
   - Unlike a typical VM (in VirtualBox, VMware, etc.) where you can use bridged networking, WSL 2 doesn't support bridged mode natively.
2. **Port Forwarding Required for External Access:**
   - Since WSL 2 instances don’t get their own IP address on the main network, you need to use port forwarding to access services inside WSL from outside (e.g., for SSH or other services like web servers).
3. **Each WSL 2 Instance has a Different Internal IP:**
   - Every time you start a WSL 2 instance, it may receive a different internal IP address, which adds some complexity to automating connections.

Now, let’s adapt the earlier steps to be more specific for WSL 2.

#### Step 1: Set Up SSH in WSL 2

To connect WSL 2 instances with Ansible, the first thing is to ensure that SSH is properly set up and accessible.

##### a. Install the SSH Server

Install and configure an SSH server inside each WSL 2 instance:

- Update and Install OpenSSH Server:

  ```bash
  $ sudo apt update
  $ sudo apt install openssh-server
  ```

- Start the SSH Service:

  ```bash
  $ sudo service ssh start
  ```

- Optional: Configure SSH to Start Automatically. Add the following to your `.bashrc` or `.zshrc` to start SSH automatically when launching **WSL** or add it on `symstemctl`:

  ```bash
  # Start SSH service
  $ sudo service ssh start
  # Check the status of SSH service
  sudo systemctl status ssh
  # Enable to start on init
  sudo systemctl enable ssh
  sudo systemctl start ssh
  sudo systemctl is-enabled ssh
  ```

##### b. Configure Port Forwarding for SSH in WSL 2

Since WSL 2 is NATed, the Linux instances don't have a directly routable IP address. You need to forward a port from Windows to the WSL 2 instance.

- **Find the Internal IP of the WSL 2 Instance: Inside the WSL instance, run:**

  ```bash
  $ ip a
  ```

- **Look for the IP under the eth0 interface (usually something like 172.x.x.x).**
  Forward Ports Using `netsh ` in PowerShell: Open PowerShell as Administrator and set up port forwarding.
  For example, to forward port 2222 on Windows to port 22 (SSH) in WSL:

  ```powershell
  $ netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=2222 connectaddress=<WSL IP> connectport=22
  # Some example with our machines
  $ netsh interface portproxy add v4tov4 listenaddress=0.0.0.0 listenport=1234 connectaddress=172.26.16.1 connectport=22
  ```

  Replace <WSL IP> with the IP address of your WSL 2 instance (172.x.x.x). 
  Repeat this for each WSL instance, assigning a different listen port for each one (e.g., 2222, 2223, etc.).

- **Set Up Firewall Rules (Optional):**
  If your firewall blocks incoming connections, you may need to add a rule to allow traffic through the forwarded ports (2222, 2223, etc.).

#### Step 2: Set Up Ansible to Manage WSL 2 Instances

Once SSH is set up and port forwarding is configured, you can connect to your WSL 2 instances using Ansible from your host (or any machine on the same network if you forward the ports correctly).

a. Create an Ansible Inventory File
Ansible uses an inventory file to define the hosts it manages. For WSL 2, you'll treat your Windows host’s IP (typically 127.0.0.1) as the target, but with different SSH ports for each WSL 2 instance.

Create the Inventory File (inventory.ini):

ini
Copy code
[wsl-instances]
wsl1 ansible_host=127.0.0.1 ansible_port=2222 ansible_user=<your_wsl_user> ansible_private_key_file=~/.ssh/id_rsa
wsl2 ansible_host=127.0.0.1 ansible_port=2223 ansible_user=<your_wsl_user> ansible_private_key_file=~/.ssh/id_rsa
Replace:

ansible_host with 127.0.0.1 (your Windows host).
ansible_port with the port you set up in the port forwarding step (e.g., 2222, 2223, etc.).
ansible_user with your WSL user.
ansible_private_key_file with the path to your SSH private key (you can generate one inside your WSL instance and copy it to your control machine if necessary).
b. Test the SSH Connection
Before running Ansible, test that you can SSH into your WSL instances using the forwarded ports. From your control machine (or Windows), try connecting via SSH:

bash
Copy code
ssh -p 2222 <your_wsl_user>@127.0.0.1
If this works, then Ansible will be able to connect.

c. Test the Ansible Connection
Run a basic Ansible ping test to check connectivity to the WSL instances:

bash
Copy code
ansible -i inventory.ini wsl1 -m ping
This should return a pong if the connection is successful.

## Quick summary of System CTL commands:

Explanation of Commands:

- `systemctl start <service>`: Starts the service immediately (in this case, SSH).
- `systemctl enable <service>`: Enables the service to start automatically at system boot.
- `systemctl status <service>`: Shows the current status of the service (running, stopped, etc.).
- `systemctl is-enabled <service>`: Checks if the service is enabled to start on boot.
- `systemctl stop <service>`: Stops the service immediately.
- `systemctl disable <service>`: Disables the service from starting at boot.

## Nice Readings

* [Software Architecture Patterns](https://dev.to/somadevtoo/9-software-architecture-patterns-for-distributed-systems-2o86)