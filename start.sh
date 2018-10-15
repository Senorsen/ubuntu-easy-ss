#!/bin/sh -e

cd $(dirname $0)
echo "Project Kobayashi (provided by Senorsen) is starting..."
echo
test -f ss-config.json || (echo "Error: no ss config detected."; exit 1)
test -f ss-ip.txt || (echo "Error: no ss ip config detected."; exit 1)

SSIP=$(cat ss-ip.txt)
IP=$(ip a | grep "scope global" | grep -Po '(?<=inet )[\d.]+' | head -n 1)
NETMASK=$(ifconfig | grep $IP | awk '{ print $4 }')

echo "******************************************************************"
echo " In your Switch, lookup and remember your current IP address, and"
echo " manually change your network configuration like this:"
echo
echo "    IP Address  :     (same as above, you remembered)"
echo "    Subnet Mask :     $NETMASK"
echo "    Gateway     :     $IP"
echo "    Primary DNS :     $IP"
echo
echo "******************************************************************"
echo

ip rule add fwmark 0x01/0x01 table 100 2>/dev/null >/dev/null || true
ip route add local 0.0.0.0/0 dev lo table 100 2>/dev/null >/dev/null|| true

# WARNING: Unsafe!!
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X
# Firewall
iptables -t filter -I FORWARD -j ACCEPT
# NAT-TCP
iptables -t nat -A PREROUTING -d 192.168.0.0/16 -j RETURN
iptables -t nat -A PREROUTING -d 172.16.0.0/12 -j RETURN
iptables -t nat -A PREROUTING -d 10.0.0.0/8 -j RETURN
iptables -t nat -A PREROUTING -d 127.0.0.0/24 -j RETURN
iptables -t nat -A PREROUTING -d $SSIP -j RETURN
iptables -t nat -A PREROUTING -d 8.8.8.8 -j RETURN
iptables -t nat -A PREROUTING -p tcp -j REDIRECT --to-ports 10707
iptables -t nat -A POSTROUTING -j MASQUERADE
# MANGLE-UDP
iptables -t mangle -A PREROUTING -p tcp -j RETURN
iptables -t mangle -I PREROUTING -d 127.0.0.0/24 -j RETURN  
iptables -t mangle -I PREROUTING -d 192.168.0.0/16 -j RETURN  
iptables -t mangle -I PREROUTING -d 10.0.0.0/8 -j RETURN  
iptables -t mangle -I PREROUTING -d 0.0.0.0/8 -j RETURN  
iptables -t mangle -I PREROUTING -d 10.0.0.0/8 -j RETURN  
iptables -t mangle -I PREROUTING -d 172.16.0.0/12 -j RETURN  
iptables -t mangle -I PREROUTING -d 224.0.0.0/4 -j RETURN  
iptables -t mangle -I PREROUTING -d 240.0.0.0/4 -j RETURN  
iptables -t mangle -I PREROUTING -d 169.254.0.0/16 -j RETURN  
iptables -t mangle -I PREROUTING -d 255.255.0.0/8 -j RETURN
iptables -t mangle -A PREROUTING -d 8.8.8.8 -j RETURN
iptables -t mangle -A PREROUTING -d $SSIP -j RETURN
iptables -t mangle -A PREROUTING -p udp -j TPROXY --on-port 10707 --tproxy-mark 0x01/0x01

# Start dnsmasq
systemctl restart dnsmasq
# Start shadowsocks
ss-redir -v -u -c ./ss-config.json
