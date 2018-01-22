#!/bin/bash
# Arguments:
# 1. The last byte of your IP

if [ "$#" < 1 ]; then
	echo "- No IP is given!"
	exit 1
fi

con_name=$(nmcli -f NAME -m multiline con show | awk '{ \
	for (i=2;i<=NF;i++) { \
		printf("%s ", $i); \
	} \
	printf("\n"); \
}' | sed 's/\s*$//')
echo "- Connection name: $con_name"
local_domain=$(hostname -I | awk -F'.' '{print $1"."$2"."$3"."}')
ip=$local_domain$1
echo "- New IP: $ip"
gateway=$(ip route | awk '/default via [0-9.]*/{print $3}')
echo "- New gateway: $gateway"
dns="8.8.8.8 8.8.4.4"
echo "- New DNS: $dns"

# https://askubuntu.com/questions/246077/how-to-setup-a-static-ip-for-network-manager-in-virtual-box-on-ubuntu-server
# https://unix.stackexchange.com/questions/349607/nmcli-commands-for-static-ip-networking-in-centos-7
echo "- Applying..."
nmcli con mod "$con_name" ipv4.addresses "$ip/24" ipv4.gateway "$gateway" ipv4.dns "$dns" ipv4.method "manual"

echo "- Restarting Network Manager..."
sudo systemctl restart NetworkManager

echo "- Done!"