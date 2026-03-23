![Logo](https://www.infogiciel.com/ipbandit/logo.png)

# IPBANDIT
IP blacklist aggregator

*currently in alpha version v0.0.1*

About
----
IPbandit is a tool that protects you from malicious IP addresses and CIDR blocks (IPv4/IPv6).\
IPbandit aggregates several blacklists built by communities. You can choose your lists, add or remove them. And you can add your own blacklists.

Licence 
----
GNU GPLv3

Roadmap
----
- 2026-01 Init project
- 2026-03 Share on github
- coming soon, add IPv6
- coming soon, extras option Fail2ban
- coming soon, extras option IPset / Iptables
- coming soon, extras option UFW / Firewalld


## HOW TO
**Warning: You must be root or use the sudo command**

Navigate to the directory where you want to install it (for example, in /etc/).

### Install

#### Git clone project
```bash
cd /etc/
git clone https://github.com/cl3m4x1l/IPbandit.git
```

#### Or download zip with wget
```bash
wget https://github.com/cl3m4x1l/IPbandit/archive/refs/heads/main.zip
unzip main.zip 
mv IPbandit-main /etc/IPbandit
```

#### Access rights 
Navigate to the parent directory

```bash
cd /etc/
chown -R root:root IPbandit
chmod +x IPbandit/IPbandit.sh
```


### Run

#### You can choose to run the script manually.
```bash
cd /etc/IPbandit/
./IPbandit.sh
```

#### Or automate it using cron. You can use `crontab -e`, but I recommend creating a file in `/etc/cron.d`.
```bash
touch /etc/crond.d/IPbandit
```

Edit the file
```bash
nano /etc/crond.d/IPbandit
```

Add this line, and adjust time
```bash
30 05 * * * root /etc/IPbandit/IPbandit.sh >> /var/log/cron.log 2>&1
```


### Results
After execution, you will find the generated files in IPbandit/list.d directory, which you can then use for your services.
- IPbandit_all.txt
- IPbandit_ipv4.txt
- IPbandit_ipv4_subnet.txt
- IPbandit_ipv6.txt
- IPbandit_ipv6_subnet.txt


## CUSTOMIZE

wait, this part isn't over yet....

__Important !__ Name your files with the .list extension.

### Static lists
You can add your own lists to the extras/list.d directory.

### Dynamic lists
You can choose which lists to download by editing the IPbandit.sh file.
