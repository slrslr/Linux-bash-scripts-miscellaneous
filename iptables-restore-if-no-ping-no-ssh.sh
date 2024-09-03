#!/bin/bash

# Linux bash script that checks if localhost is responding to a ping and if iptables contains yours defined phrase.
# If any of the two options is false, then it restores iptables configuration and restarts wireguard VPN service (in order to apply iptables forwarding rules from wg0.conf)

# Basically you need to:
# 1) replace "ssh -j ACCEPT" by your own phrase from the output of a "iptables-save" command
# 2) replace "/etc/iptables/rules.v*" paths by your own paths of a valid/desired iptables rules files produced by the "iptables-save > filev4" and "ip6tables-save > filev6" commands
# 3) replace or delete systemctl command if you are not using Wireguard VPN
# 4) Doublecheck the file, set it as executable "chmod +x thisscriptname" and then add a new cronjob "crontab -e" to run minutely: * * * * * /bin/bash /path/to/thisscript.sh

if ! ping -c 1 "127.0.0.1" &> /dev/null || ! /usr/sbin/iptables-save|grep "ssh -j ACCEPT" &> /dev/null; then
/usr/sbin/iptables-restore < /etc/iptables/rules.v4
/usr/sbin/ip6tables-restore < /etc/iptables/rules.v6
systemctl restart wg-quick@wg0.service
exit 1
fi
