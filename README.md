# wgQR
--------------------
wgQR is a Wireguard client configuration tool. It eases the enrollment of new clients on your private WG server.

### `wg-quick` lets you easily bring up new interfaces, `wgQR` makes enrolling clients on them a breeze.

It's designed for micro-scale VPNs and homelab-style use cases. The script should be run on the WG server, since the client key pair will be generated on it.

## Dependencies
`qrencode` for in-terminal QR code generation. Makes setting up mobile devices as easy as scanning a QR code with the wireguard app. Recommended!

## UX flow:
1. Run this script and specify a client name.
2. Client keys will automatically be generated, a client IP will be allocated and a properly formatted `client.conf` will be saved and displayed in a QR code for easy mobile deployment.


## Usage:
1. Create a Wireguard interface [for example using `wg-quick`](https://man7.org/linux/man-pages/man8/wg-quick.8.html) 
```
./create.sh
--or --
./create.sh myWireguardInterface
```
