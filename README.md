# wgQR: wg Quick enRoller
wgQR is a Wireguard client configuration tool. It eases the enrollment of new clients on your private WG server and creates a QR code to configure new mobile clients easily with the Wireguard app.

> [`wg-quick`](WG-QUICK_TUTORIAL.md) lets you easily bring up new interfaces, `wgQR` makes enrolling clients on them a breeze

It's designed for micro-scale VPNs and homelab-style use cases. The script should be run on the WG server, and it'll generate the client key pair if not present.

## Dependencies:
+ `qrencode` for in-terminal QR code generation. Recommended, makes setting up mobile devices as easy as scanning a QR code with the wireguard app.
+ `wg` (oviously) and `wg-quick`

## Configuration:
This script requires the following variables to be set in `config.sh`:
+ `SRVIP` with the server's public IP address. By default, read from `./srvip.secret`.
+ `SRVPUBKEY` with the server's public key. By default, retreived from `/etc/wireguard/publickey`.

## Usage:
This script assumes and depends on at least 1 existing wireguard interface with a [`wg-quick`](https://man7.org/linux/man-pages/man8/wg-quick.8.html) compatible config in `/etc/wireguard/yourinterface.conf`. You can create one just, for example using following [the tutorial on this repo](WG-QUICK_TUTORIAL.md).

1. Run this script and specify a client name: `./create.sh myClient`
2. Select a wireguard interface from the prompted ones that will be retreived from your system.
2. Client keys will automatically be generated, an unique client IP in the subnet will be allocated and a properly formatted `client.conf` will be saved.
3. Copy `clients/myWgInterface/myClient.conf` (the correct path will be shown in the output) to your client and enable the wg interface `sudo wg-quick up configfile.conf` or scan the displayed QR code with the Wireguard app.
```text
The client's config file is saved on clients/myInterface/myClient.conf
If your client is unable to scan QR codes, copy this file to their /etc/wireguard and execute 'wg-quick up myClient'
```

## Disallowing clients:
If you want to disallow an old client from your wireguard interface, just call:
```bash
./delete.sh yourDeviceName
```
If you don't remember the name you assigned to the device, call the script without any parameters:
```bash
./delete.sh
```
And all the devices enrolled by `wgQR` will be listed.
