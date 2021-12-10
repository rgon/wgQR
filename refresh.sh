#!/bin/bash

source config.sh
source util.sh

# CMD Line args
if [ "$1" == '' ]; then
	echo "USAGE: ./refresh.sh [wgInterface OPTIONAL]"
    echo "Un-enrolls all clients from an interface and (optionally) re-enrolls them with the saved data in clients/\$interface/*.conf"
	echo ""
	
	listSetUpClients
	echo ""
	getInterface
else
	if [ -f "/etc/wireguard/${1}.conf" ]; then
		interface=$1
		echo "Operating on interface $interface"
	fi
fi

# Backup original file
cp "/etc/wireguard/${interface}.conf" "/etc/wireguard/${interface}.conf.bak"

# Remove Peer entries 
perl -0p -i -e 's/^\[Peer\][^\[]+//gms' "/etc/wireguard/${interface}.conf"

# Restart interface
read -p "Restart $interface? This WILL DROP any VPN connections. [Y/n] " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Restarting..."
    turnWgIfaceOnOff $interface restart
    echo "Interface back up."
else
    echo "Peer entries have been removed from the interface configuration file."
    echo "A backup of the original file has been made in '/etc/wireguard/${interface}.conf.bak'"
    echo "Please continue re-enrolling clients and resetting the interface or restore the original file."
    exit
fi

read -p "Re-enroll cilents? This step is required if you need the clients to work again, as intended. [Y/n] " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
	for client in ${CONFKEYDIR}/${interface}/*.conf; do
		clientConfFile=$(basename "$client")
		CLIENTIP=$(cat ${client} | grep -oP '(?<=Address = )(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})')
		clientName=${clientConfFile%.*}
		echo "Retrieving client pub key"

		clientPubKey=$(cat ${CONFKEYDIR}/${clientName}.key.pub)
		echo "Enrolling $clientName with $clientPubKey and IP $CLIENTIP"
		enrollClient $interface $clientPubKey $CLIENTIP
		sudo wg set $interface peer $clientPubKey allowed-ips $CLIENTIP/32
	done
fi

echo ""
echo "Done."
echo "A backup of the original file has been made in '/etc/wireguard/${interface}.conf.bak'"
echo "Interface ${interface} has been refreshed."