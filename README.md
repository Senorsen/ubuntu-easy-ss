# ubuntu-easy-ss
Run a shadowsocks-redir client on an Ubuntu 18.04 Live CD, for console acceleration (Project Code: Kobayashi)

This is just a demo project, it will flush your dnsmasq configuration and iptables. Use with caution (better used in Live CD environment).

Put ss-config.json and ss-ip.txt (plain text, your server ip - not domain!), and install & start using root user.

Shadowsocks's `local_port` should be `10707` , and `local_address` should be `0.0.0.0` .
