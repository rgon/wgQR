###########################
## wgQR configuration
###########################

CONFKEYDIR=clients
SRVIP=`cat srvip.secret`
SRVPUBKEY=`cat publickey.secret`

# NOTE: a file called publickey has to be present in the same directory
# NOTE: /etc/wireguard/${interface}.conf must exist
