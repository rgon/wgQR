###########################
## Util functions for wgQR
###########################

# Find set up interfaces
declare -a WGINTERFACES=()
for iface in /etc/wireguard/*.conf; do
	iface=$(basename "$iface")
	echo "Found interface ${iface%.*}"
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

