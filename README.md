# wgQR
wgQR is a Wireguard client configuration tool. It eases the enrollment of new clients on your private WG server.

> [`wg-quick`](WG-QUICK_TUTORIAL.md) lets you easily bring up new interfaces, `wgQR` makes enrolling clients on them a breeze

It's designed for micro-scale VPNs and homelab-style use cases. The script should be run on the WG server, and it'll generate the client key pair if not present.

## Dependencies:
+ `qrencode` for in-terminal QR code generation. Recommended, makes setting up mobile devices as easy as scanning a QR code with the wireguard app.
+ `wg` (oviously)

## Configuration:
This script requires the following variables to be set in `config.sh`:
+ `SRVIP` with the server's public IP address
+ `SRVPUBKEY` with the server's public key

## Usage:
This script assumes and depends on at least 1 existing wireguard interface with a [`wg-quick`](https://man7.org/linux/man-pages/man8/wg-quick.8.html) compatible config in `/etc/wireguard/yourinterface.conf`. You can create one just, for example using following [the tutorial on this repo](WG-QUICK_TUTORIAL.md).

1. Run this script and specify a client name: `./create.sh myClient`
2. Select a wireguard interface from the prompted ones that will be retreived from your system.
2. Client keys will automatically be generated, an unique client IP in the subnet will be allocated and a properly formatted `client.conf` will be saved and displayed in a QR code for easy mobile deployment.

