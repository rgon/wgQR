###########################
## Util functions for wgQR
###########################

# Dependency checks:
which qrencode 1> /dev/null
if [ $? -ne 0 ]; then
	echo "qrencode not installed! QR Code generation WILL NOT WORK"
	echo "Please install it. Command for Ubuntu 21.04:"
	echo "	sudo apt install qrencode" 
	echo "------------------------ o ------------------------"
fi

# Find set-up interfaces
ls /etc/wireguard/*.conf 1> /dev/null
if [ $? -ne 0 ]; then
	echo "Error listing wireguard interfaces on /etc/wireguard. Maybe a permission error? Please try again with sudo."
	echo "Aborted."
	exit
fi

declare -a WGINTERFACES=()
for iface in /etc/wireguard/*.conf; do
	iface=$(basename "$iface")
	# echo "Found configured wg interface ${iface%.*}"
	WGINTERFACES+=(${iface%.*})
done

# UTIL
getInterface() {
	echo "Choose which interface to authorise: "
	arraylength=${#WGINTERFACES[@]}
	for (( i=0; i<${arraylength}; i++ )); do
	   echo "${i}: ${WGINTERFACES[$i]}"
	done

	while read -p "Authorize on interface: " -r i; do
		if [ $i -lt $arraylength ] && [ $i -gt -1 ]; then
			break
		else
			echo "Chosen interface not in range."
		fi
	done

	interface=${WGINTERFACES[$i]}
}

listSetUpClients() {
	echo "Already set-up clients (interface: client):"
	
	#ls ${CONFKEYDIR}/*/*.conf
	for iface in ${CONFKEYDIR}/*/; do
		ifaceName=$(basename "$iface")
		for client in ${iface}/*.conf; do
			client=$(basename "$client")
			echo "	+ $ifaceName: ${client%.*}"
		done
	done
}

enrollClient () {
	if [ "$(cat /etc/wireguard/${1}.conf | grep $2)" == '' ]; then
		sudo tee -a /etc/wireguard/${1}.conf > /dev/null <<EOT
[Peer]
PublicKey = $2
AllowedIPs = ${3}/32
EOT
	fi
}

turnWgIfaceOnOff () {
	interface="$1"

	if [ "$2" == "on" ] || [ "$2" == "true" ]; then
    	#ip link set $interface up
		#sudo wg-quick up $interface
		sudo systemctl start wg-quick@${interface}.service
	elif [ "$2" == "restart" ]; then
		turnWgIfaceOnOff $1 off
		turnWgIfaceOnOff $1 on
	else
		#ip link set $interface down
		sudo wg-quick down $interface
		sudo systemctl stop wg-quick@${interface}.service
	fi
}