#!/bin/bash

source config.sh
source util.sh

# CMD Line args
if [ "$1" == '' ]; then
	echo "USAGE: ./delete.sh clientName"
	echo ""
	
	listSetUpClients
	exit
fi

# Main
CLIENTNAME=${1//.conf/}

if [ -f "${CONFKEYDIR}/${CLIENTNAME}.conf" ]; then
	read -p "Delete keys for $CLIENTNAME? [Y/n] " -r
	if [[ $REPLY =~ ^[Yy]$ ]]; then
	        PUBKEY=`cat ${CONFKEYDIR}/${CLIENTNAME}.key.pub`
		rm ${CONFKEYDIR}/${CLIENTNAME}.*
	fi
	
	echo "Choose which interface to remove the key from: "
	arraylength=${#WGINTERFACES[@]}
	for (( i=0; i<${arraylength}; i++ )); do
	   echo "${i}: ${WGINTERFACES[$i]}"
	done
	
	while read -p "Remove on interface: " -r i; do
		if [ $i -lt $arraylength ] && [ $i -gt -1 ]; then
			interface=${WGINTERFACES[$i]}
			sudo wg set $interface peer $PUBKEY remove
			echo "Removed $CLIENTNAME from $interface"
		else
			echo "Chosen interface not in range."
		fi
	done

	read -p "Restart wg service? Recommended, but will drop connections momentarily. [Y/n] " -n 1 -r
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		turnWgIfaceOnOff $interface restart
	fi
else
	echo "Client key with that name doesn't exist"
fi
