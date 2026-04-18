![Logo](https://www.infogiciel.com/ipbandit/logo.png)

# IPBANDIT
IP blacklist aggregator

*currently Version 1.0 __Nightly__*

About
----
IPbandit is a tool that protects you from malicious IP addresses and CIDR blocks (IPv4/IPv6).\
IPbandit aggregates several blacklists created by the community. You can select your lists, add or delete them, 
and even create your own blacklists to block entire countries, for example.
 
It's an aggregation of lists of malicious IP addresses to integrate with your firewalls: Fortinet FortiGate, Palo Alto, pfSense, OPNsense, iptables, NFtables, IPset, UFW, Firewalld, etc.

Using the default lists, you'll already block approximately 300,000 malicious IP addresses.


Licence 
----
IPbandit is free and open-source software licensed under the GNU General Public License v3.0 (GPLv3).\
You are free to use, modify, and distribute this software in compliance with the license terms. See the [LICENSE](/LICENSE) file for more details.


Roadmap
----
- 2026-01 Init project, share on github
- 2026-02 Version Alpha: IPv6, add custom config file
- 2026-03 Add Fail2ban extras option
- 2026-04 Version 1.0 NIGTHLY
- 2026-05 Version 1.0 BETA
- 2026-07 Version 1.0 RC (Release Candidate)
- 2026-09 Version 1.0 STABLE
- coming soon, extras option IPset / Iptables
- coming soon, extras option UFW / Firewalld


## HOW TO

You can use our lists generated directly from our web servers (default configuration) without installation.\
Download the following files directly
- https://raw.githubusercontent.com/cl3m4x1l/IPbandit/refs/heads/main/list.d/IPbandit_all.txt
- https://raw.githubusercontent.com/cl3m4x1l/IPbandit/refs/heads/main/list.d/IPbandit_ipv4.txt
- https://raw.githubusercontent.com/cl3m4x1l/IPbandit/refs/heads/main/list.d/IPbandit_ipv4_subnet.txt
- https://raw.githubusercontent.com/cl3m4x1l/IPbandit/refs/heads/main/list.d/IPbandit_ipv6.txt
- https://raw.githubusercontent.com/cl3m4x1l/IPbandit/refs/heads/main/list.d/IPbandit_ipv6_subnet.txt


### Install

#### Git clone project
```bash
mkdir /opt/clemaxil
cd /opt/clemaxil/
git clone https://github.com/cl3m4x1l/IPbandit.git
```

#### Or download zip with wget
```bash
mkdir /opt/clemaxil
cd /opt/clemaxil/
wget https://github.com/cl3m4x1l/IPbandit/archive/refs/heads/main.zip
unzip main.zip 
mv IPbandit-main IPbandit
```

#### Access rights 
Navigate to the parent directory

```bash
cd /opt/clemaxil/
chown -R root:root IPbandit
chmod +x IPbandit/IPbandit.sh
```


### Run

#### You can choose to run the script manually.
```bash
cd /opt/clemaxil/IPbandit/
./IPbandit.sh
```

#### Or automate it using cron. You can use `crontab -e`, but I recommend creating a file in `/etc/cron.d`.
```bash
nano /etc/crond.d/IPbandit
```

Add this line, and adjust time
```bash
30 05 * * * root nice -n 10 /opt/clemaxil/IPbandit/IPbandit.sh 2>&1
```


### Results
After execution, you will find the generated files in IPbandit/list.d directory, which you can then use for your services.
- IPbandit_all.txt
- IPbandit_ipv4.txt
- IPbandit_ipv4_subnet.txt
- IPbandit_ipv6.txt
- IPbandit_ipv6_subnet.txt


## CUSTOMIZE

Note: IPdeny offers free downloads of GEO IP address blocks by country. You can add a list of IP addresses from a country to this directory. https://www.ipdeny.com/ipblocks/

### Personnal lists
You can add your own lists to the extras/list.d directory.
__Important !__ Name your files with the .list extension.


### External lists
You can choose which lists to download by editing the IPbandit_custom.txt file.


## EXTRAS

### Fail2ban
You can first retrieve the list of IPs detected by fail2ban on your machine.

To do this, run the fail2ban.sh script in the extras directory. \
The script will write the myfail2ban.list file to the extras/list.d directory. \
This file will then be imported directly by IPbandit.

```bash
nano /etc/crond.d/IPbanditFail2ban
```

Add this line, and adjust time for run before IPbandit.sh
```bash
00 05 * * * root nice -n 10 /opt/clemaxil/IPbandit/extras/fail2ban.sh 2>&1
```
