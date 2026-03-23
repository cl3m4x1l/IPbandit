![Logo](https://www.infogiciel.com/ipbandit/logo.png)

# IPbandit
IP blacklist aggregator

About
----
IPbandit is a tool that protects you from malicious IP addresses and CIDR blocks (IPv4/IPv6).\
IPbandit aggregates several blacklists built by communities. You can choose your lists, add or remove them. And you can add your own blacklists.

### Licence : GNU GPL v3

Roadmap
----
- 2026-01 Init project
- 2026-03 Share on github
- coming soon, add IPv6
- coming soon, extras option Fail2ban
- coming soon, extras option IPset / Iptables
- coming soon, extras option UFW / Firewalld


### INSTALL
Navigate to the directory where you want to install it (for example, in /etc/).

<p style="color:orange">__Warning:__</p> You must be root or use the sudo command

#### Git clone project
```bash
git clone https://github.com/cl3m4x1l/IPbandit.git
```

#### Or download zip with wget
```bash
wget https://github.com/cl3m4x1l/IPbandit/archive/refs/heads/main.zip
unzip main.zip 
mv IPbandit-main IPbandit
```

You can choose to run the script manually.
```bash
./IPbandit.sh
```

Or to automate using cron



