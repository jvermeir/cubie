#!/bin/bash

#reset iptables; drop all rules
iptables -F
iptables -X


#allow loop
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT


# ALLOW DNS
iptables -A INPUT -p udp --sport 53 -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT


# ALLOW ICMP
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT


iptables -A OUTPUT -o eth0 -p tcp -j ACCEPT
iptables -I INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT


# insert everything you want to allow -->

# ALLOW incoming SSH from eth0
iptables -A INPUT -i eth0 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

# ALLOW incoming HTTP
iptables -A INPUT -i eth0 -p tcp --dport 8080 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp --sport 8080 -m state --state ESTABLISHED -j ACCEPT

# DROP rest
iptables -A INPUT -j REJECT
iptables -A OUTPUT -j REJECT

## Now we've got an iptables config, persist changes

iptables -L > /etc/iptables.rules
cp 01firewall /etc/NetworkManager/dispatcher.d/01firewall
chmod +x /etc/NetworkManager/dispatcher.d/01firewall
