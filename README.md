# Greenhouse Ivy - Automations & Utils
## Ansible

### Configuration

To configure the project, we have created the folder `/etc/greenhouse/ansible` that will contain all necessary configs.

See below the three of folders:

```
+--- /
     |--- /ansible
          |--- /ivy-automation
          |--- /config
              |--- /ssh
              |--- inventory
```

#### Inventory

File that will contain the list of IP, hostnames or DNS names that Ansible will manage.

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

```bash
$ ansible-vault create \
    --vault-password-file /greenhouse/ansible/config/secrets/ansible_vault_password \
    /greenhouse/ansible/config/secrets/vault.yml
  
$ ansible-vault edit \
    --vault-password-file /greenhouse/ansible/config/secrets/ansible_vault_password \
    /greenhouse/ansible/config/secrets/vault.yml
```

[ansible.cfg](./ansible/ansible.cfg)

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

## Nice Readings

* [Software Architecture Patterns](https://dev.to/somadevtoo/9-software-architecture-patterns-for-distributed-systems-2o86)