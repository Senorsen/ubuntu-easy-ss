#!/bin/sh

cd $(dirname $0)
echo "Installing shadowsocks, dnsmasq and net-tools..."
sudo apt install -y shadowsocks-libev dnsmasq net-tools ipset
sudo cp /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
sudo cp dnsmasq.conf /etc/
