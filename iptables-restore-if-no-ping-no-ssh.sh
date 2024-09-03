#!/bin/bash

# Linux bash script that checks if 1) localhost is responding to a ping and if 2) localhost accepts connections on a defined port (e.g. ssh 22) and if 3) iptables contains defined phrase (i.e. wanted rule exist).
# If any of the three options is false, then it restores iptables configuration and restarts wireguard VPN service (in order to apply iptables forwarding rules from wg0.conf)

# Basically you need to:
# 1) replace 3 variables below if needed
# 2) replace "/etc/iptables/rules.v*" paths by your own paths of a valid/desired iptables rules files produced by the "iptables-save > filev4" and "ip6tables-save > filev6" commands
# 3) replace or delete systemctl command if you are not using Wireguard VPN
# 4) doublecheck this script file content, set it as executable "chmod +x thisscriptname" and then add a new cronjob "crontab -e" to run minutely: * * * * * /bin/bash /path/to/thisscript.sh

host="127.0.0.1" # hostname to check
port="22" # hostname port to check if accepts connection. By default TCP, for UDP, replace zvw by zvuw in a nc command.
iptphrase="ssh -j ACCEPT" # phrase from a iptables -S output to check if exist

if ! ping -c 1 "$host" &> /dev/null || ! nc -zvw 10 "$host" "$port" &> /dev/null || ! /usr/sbin/iptables-save|grep "$iptphrase" &> /dev/null; then
/usr/sbin/iptables-restore < /etc/iptables/rules.v4
/usr/sbin/ip6tables-restore < /etc/iptables/rules.v6
systemctl restart wg-quick@wg0.service
exit 1
fi
