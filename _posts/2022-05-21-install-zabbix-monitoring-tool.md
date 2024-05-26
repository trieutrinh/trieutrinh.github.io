---
title: Install Zabbix Monitoring Tool
description: |-
  Zabbix server is installable on any Linux distribution, but in this tutorial, I will show you step-by-step how to install and optimize the latest Zabbix 6.0 on RHEL 8.5. Zabbix is 100% free open-source ultimate enterprise-level software designed for monitoring availability and performance of IT infrastructure components.

categories: "Tool"
tags:
  - Monitoring
  - Zabbix
  - Server

# img_path: /assets/img/posts/2022-05-21-install-zabbix-monitoring-tool/
image:
  path: /assets/img/posts/2022-05-21-install-zabbix-monitoring-tool/header.jpg
  lqip: ""  # TODO

date: 2022-05-21
---

First, we will install and configure Zabbix server, then a database and lastly the frontend - check the picture bellow for a better understanding of Zabbix architecture

![Zabbix-architecture](/assets/img/posts/2022-05-21-install-zabbix-monitoring-tool/zabbix_architecture.jpg)
_Picture showing Zabbix Architecture_

This guide is for installing Zabbix monitoring system (Server) on RHEL


## Install Zabbix server, frontend and agent

> **Note:** you need to log in as a root user on your Linux server with "su -" or use "sudo" to successfully execute commands used in thi tutorial.

Install **Zabbix 6** .deb package on your Ubunutu OS (22.04, 20.04 are supported).


> Zabbix 6.0 LTS version (supported until February, 2027)
```bash
wget https://repo.zabbix.com/zabbix/6.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.0-4+ubuntu$(lsb_release -rs)_all.deb
sudo dpkg -i zabbix-release_6.0-4+ubuntu$(lsb_release -rs)_all.deb
sudo apt update
sudo apt -y install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent
```

You can find more information about [Zabbix's life cycle and release policies](https://www.zabbix.com/life_cycle_and_release_policy) on the official website.  

## Configure database

In this installation, I will use password `PassW0rd` as root password and `zabbixDBpass` as Zabbix password for DB. Consider changing password for security reasons.

### Install MariaBB 10.6

In your termial, use the following command to install MariaDB 10.6.

```bash
sudo apt install software-properties-common -y
```

```bash
curl -LsS -O https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
sudo bash mariadb_repo_setup --mariadb-server-version=10.6
```

Once the installation is complete, start the MariaDB service and enable it to start on boot using the following commands:

```bash
sudo systemctl start mariadb
sudo systemctl enable mariadb
```

### Reset root password for database

Secure MySQL/MariaDB by changing the default password for MySQL root:

```bash
sudo mysql_secure_installation
```

>Enter current password for root (enter for none): `Press Enter`  
Switch to unix_socket authentication [Y/n] `y`  
Change the root password? [Y/n] `y`  
New password: `<Enter root DB password>`  
Re-enter new password: `<Repeat root DB password>`  
Remove anonymous users? [Y/n]: `y`  
Disallow root login remotely? [Y/n]: `y`  
Remove test database and access to it? [Y/n]: `y`  
Reload privilege tables now? [Y/n]: `y`

### Create database

```bash
sudo mysql -uroot -p'rootDBpass' -e "create database zabbix character set utf8mb4 collate utf8mb4_bin;"
sudo mysql -uroot -p'rootDBpass' -e "create user 'zabbix'@'localhost' identified by 'zabbixDBpass';"
sudo mysql -uroot -p'rootDBpass' -e "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbixDBpass';"
```

### Import initial schema and data

Import database schema for Zabbix server (could last up to 5 minutes)

```bash
sudo zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p'zabbixDBpass' zabbix
```

### Enter database password in Zabbix configuration file

Open zabbix_server.conf file with command:

```bash
sudo vi /etc/zabbix/zabbix_server.conf
```

and add database password in this format anywhere in file:

>DBPassword=`zabbixDBpass`

Save and exit file (**Esc**, followed by **:wq** and **enter**).

## Configure firewall

If you have a UFW firewall installed on Ubuntu, use these commands to open TCP ports: 10050 (agent), 10051 (server) and 80 (frontend):

```bash
ufw allow 10050/tcp
ufw allow 10051/tcp
ufw allow 80/tcp
ufw reload
```

## Start Zabbix server and agent processes

```bash
sudo systemctl restart zabbix-server zabbix-agent
sudo systemctl enable zabbix-server zabbix-agent
```

{% include embed/youtube.html id='ktUQHptEPHg' %}

| Syntax      | Description |
| --- | ----------- |
| Header      | Title       |
| Paragraph   | Text        |


Gone camping! :tent: Be back soon. 😚 

- [x] Write the press release
- [ ] Update the website
- [ ] Contact the media

#### Decryption Script

```bash
#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

force=false

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -f|--force)
            force=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done
```
{: file='scripts/sops-decrypt-all.sh'}

---


### Taskfile to the Rescue!

![Taskfile Logo](/assets/img/posts/2022-05-21-install-zabbix-monitoring-tool/taskfile_logo.webp)
_Taskfile Logo_


Finally, my last gripes with this setup are quite trivial and minor, but while I was at it I decided to solve everything.

First off, I wanted to be able to run those two scripts without having to be mindful of where I am in my repository relative to the root. I wanted to just run a command and have it do its magic.

Secondly, I am lazy and even having to type `bash scripts/sops-encrypt-all.sh` is quite a lot. I'd need an alias or something for this.

Well, thankfully I was already using `Taskfile` in my HomeOps repository for other things, so it will also nicely handle all these my complaints.

I will not cover what Taskfile is, how to use it or how to set it up in this post, as it is outside of the scope. Think of this as a teaser, an "exercise left for the reader" if you will 😉

What I had to do to set this up is that I had to add this snippet in my `Taskfile.yaml`:

```yaml
---
version: '3'

includes:
  sops: .taskfiles/sops.yaml

...
```
{: file='Taskfile.yaml'}

Which includes this sub-taskfile from my `.taskfiles` directory under the `sops` namespace:

{% raw %}
```yaml
---
# yaml-language-server: $schema=https://taskfile.dev/schema.json
version: '3'

tasks:
  encrypt:
    aliases: [enc,e]
    desc: Encrypt all sops files in this repository.
    run: once
    cmds:
      - bash {{.ROOT_DIR}}/scripts/sops-encrypt-all.sh

  decrypt:
    aliases: [dec,d]
    desc: Decrypt all sops files in this repository.
    run: once
    cmds:
      - bash {{.ROOT_DIR}}/scripts/sops-decrypt-all.sh {{.CLI_ARGS}}
```
{: file='.taskfiles/sops.yaml'}
{% endraw %}

This essentially allows me to run:

- `task sops:encrypt` / `task sops:enc` / `task sops:e` to encrypt all of my secret files
- `task sops:decrypt` / `task sops:dec` / `task sops:d` to decrypt all of my secret files

It all depends on how lazy I'm feeling, really 😆

## Conclusion

![That's all Folks](http://wallpapers.net/web/wallpapers/thats-all-folks-hd-wallpaper/1500x500.jpg)
_image from [wallpapers.net](http://wallpapers.net/thats-all-folks-hd-wallpaper/1500x500)_

And that's a wrap, folks! We can *finally* push our secrets in git without losing sleep over it!

We covered quite a bit of ground in this post. We started from the bottom by seeing how `age` works by itself. Then, we went one layer of abstraction higher by checking out `sops`, and we finally created our own abstraction layer on top of `sops` with some `bash` scripts and `Taskfiles` that automate our secret management end-to-end.

What is your preffered tool/stack to manage your secrets and why? Let me know in the comments section down below what you are using and how it compares to `age` and `sops`.

Until next time, keep safe, keep encrypting! 🛡️🔒

---

{% include embed/youtube.html id='wqD7k5iNvqs' %}
📹 [Watch Video](https://youtu.be/wqD7k5iNvqs)

<font color="red">This text is red!</font>
