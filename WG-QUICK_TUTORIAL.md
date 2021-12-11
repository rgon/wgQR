# Setting up a Wireguard interface from scratch using `wg-quick`
A no-bs and easy-to-read guide on how to set up your own Wireguard VPN server. Tested on `Ubuntu 21.04`, but is valid for other distros with simple adjustments.

## Installation requirements:
Before continuing, install the required dependencies:
+ `sudo apt install wireguard`
+ `sudo apt install ufw` For simple firewall configuration. If this is the first time installing it, don't forget to enable your ssh port or any other you require for access! `sudo ufw allow ssh` Enable it with `sudo ufw enable`
+ `sudo sed -E -i 's/#net.ipv4.ip_forward=1|net.ipv4.ip_forward=0/net.ipv4.ip_forward=1/' /etc/sysctl.conf && sudo sysctl -p` enable routing

## Step 1: Server key pair generation
This command will create a new key pair for your server, and these keys will be shared for all interfaces running on the same machine. They will uniquely identify this VPN server for your clients. 

This step only has to be performed once.
```bash
cd /etc/wireguard
umask 077
wg genkey | tee privatekey | wg pubkey > publickey
```

## Step 2: Wireguard interface configuration
For every wireguard interface you wish to create (in this case, we named it `wg0`, but you can use a more descriptive name such as `homelabvpn`), create a file with the contents (edit those in `<brackets>`:
```bash
sudo nano /etc/wireguard/wg0.conf
```
```config
[Interface]
PrivateKey = <contents-of-/etc/wireguard/privatekey>
Address = 10.0.0.1/24
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
ListenPort = 51820
```
If you need inter-client communication, enable it as well:
```
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; iptables -A FORWARD -i wg0 -o wg0 -j ACCEPT
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; iptables -D FORWARD -i wg0 -o wg0 -j ACCEPT
```
There is no need to set up clients here, `wgQR` will set them up for you.

<details>
<summary>Common config options</summary>
<br>
+ *WG Interface subnet:* `Address = 10.0.0.1/24`. Clients connecting to this wireguard VPN will take the IPs: `10.0.0.2`, `10.0.0.3`, `10.0.0.21` etc. Make sure that your WAN interface is not in this same subnet, as every interface should be in a different subnet to make things easy. When creating more than 1 wireguard interface in the same server, make sure that every one of them is on a different subnet (eg. wgHomelab on `10.0.0.1/24`, wgProjects on `10.0.10.1/24`, wgHomelab on `10.0.3.1/24`). This way, every wireguard interface will have their clients isolated.
+ *WG Interface port*:  `ListenPort = 51820`. Every wireguard interface in this machine must have an unique ListenPort. Choose any port that is free on the machine. 
</details>

## Step 3: Allow access to the interface
Allow the port we previously defined on the firewall:
```bash
sudo ufw allow 51820
```

## Step 4: Starting wireguard as a service
Start the wireguard interface (in this case, `wg0`) with:
```bash
sudo wg-quick up wg0
```
In case you want this interface to be started on every boot (most likely the case if this is your VPN server), enable the wg-quick server with your interface tag:
```bash
sudo systemctl enable wg-quick@wg0
```

## Step 5: Enroll clients
This is where the tool [wgQR](https://github.com/rgon/wgQR) becomes very helpful. Download it:
```bash
git clone https://github.com/rgon/wgQR
cd wgQR
```
0. Tell the clients what the server's public IP is.
```bash
curl https://api.ipify.org --output srvip.secret
```
1. Run wgQR/create.sh and specify a client name: `./create.sh myClient`
2. Select a wireguard interface from the prompted ones that will be retreived from your system.
2. Client keys will automatically be generated, an unique client IP in the subnet will be allocated and a properly formatted `client.conf` will be saved and displayed in a QR code for easy mobile deployment.

Done! Scan the QR code with the Wireguard app on your phone and everything will be set.

## Troubleshooting:

### If your wireguard server or client is behind NAT:
If a connection between both clients cannot be established, or only works on certain hard-to-specify conditions.
> *Example use case:* you want to connect to a fellow client of yout network through the VPN.
```text
            ______________
           |  VPN Server  |
           |______________|
            ^             ^
            |             |
       ( homePC ) <--> ( phone )
            between clients
```

+ *FIX:* add the following line to both client's `interface.conf` file: `PersistentKeepAlive = 25`
+ *WHAT IT DOES*: the client will ping the server every **25s**
+ *REASON:* the (stateful) router of which the client is in will drop the connection if no activity is detected for a certain period of time. For this reason, to keep the connection open so one client can reach anocher, a persistent ping every so often is performed.

### Connection not working:
If the interfaces go up correctly but no traffic flows, enable wireshark debugging on the server and check the logs `dmesg` when the client connects.
```
modprobe wireguard && echo module wireguard +p > /sys/kernel/debug/dynamic_debug/control
```
Also check if the key pairs are correct by generating the public key out of the private and comparing it to the value elsewhere:
```
echo {PRIVATEKEY} | wg pubkey
```