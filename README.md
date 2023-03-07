Roll Your Own VPN with SoftEther
---
SoftEther is probably one of the best VPNs yet rather obscure. This guide gives you a short intro
on how to build and run SoftEther in a Docker container. 

*WARNING: Please mind that for production use you have to harden the VPN server. Do not let incomming 
traffic unless you made proper configuration changes.*

# Build
The following script builds the Docker image for the amd64 platform.
```bash
./build_image.sh
# Check the build
docker run -it --rm sevpn:amd64
```
All checks should pass.

If you need a shell with the image:
```bash
docker run -it --rm --entrypoint "/bin/bash" sevpn:amd64
```

# Package
Package the image and support files:
```bash
./pack.sh
```
Copy the tgz files to the destination host and unpack eg. to /opt/docker/sevpn.

# Prepare
For production use create a Docker network and set the Docker host's IP address 
in adminip.txt.

```bash
docker network create sevpn
docker network inspect sevpn | jq .[]."IPAM"."Config"
# Put Gateway IP to adminip.txt and start the VPN server in attached mode
./start.sh
```

Connect to the VPN server with the vpncmd utility:
```bash
./vpncmd.sh
```

## Hardening
Run the following commands in ./vpncmd.sh
```bash
KeepDisable
ServerCertRegenerate sevpn
ServerCipherSet TLS_AES_128_GCM_SHA256
VpnAzureSetEnable no
VpnOverIcmpDnsEnable /ICMP:no /DNS:no
ProtoOptionsSet OpenVPN /NAME:Enabled /VALUE:false
ProtoOptionsSet SSTP /NAME:Enabled /VALUE:false
ProtoOptionsSet wireguard /NAME:Enabled /VALUE:true
Flush
Exit
```
or run the following command script
```bash
./vpncmd.sh sevpn /SERVER /IN:/init.txt
```
Stop the server
```bash
docker stop sevpn
```
and edit the config file (data/vpn_server.config) and change the following settings
```bash
declare DDnsClient
  bool Disabled true
declare ServerConfiguration
  bool DisableIPv6Listener true
  bool DisableJsonRpcWebApi true
  bool DisableNatTraversal true
  Tls_Disable1_0 true
  Tls_Disable1_1 true
  Tls_Disable1_2 true
  Tls_Disable1_3 false
```
Start the server:
```bash
./start.sh
```
and heck config changes
```bash
./vpncmd.sh sevpn /SERVER /CMD ConfigGet
```

## Admin Password
```bash
pass=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
./vpncmd.sh sevpn /SERVER /CMD ServerPasswordSet $pass
echo $pass > ./data/admin.txt
unset pass
```
or run
```bash
./admin_password.sh
```

## Wireguard Key
```bash
./vpncmd.sh sevpn /TOOLS /CMD:GenX25519 > ./data/wg_server.key
./vpncmd.sh sevpn /TOOLS /CMD:GenX25519 > ./data/wg_psk.key
private_key=$(cat ./data/wg_server.key | grep Private | cut -d " " -f 3)
./vpncmd.sh sevpn /SERVER /CMD ProtoOptionsSet wireguard /NAME:PrivateKey /VALUE:$private_key
private_key=$(cat ./data/wg_psk.key | grep Private | cut -d " " -f 3)
./vpncmd.sh sevpn /SERVER /CMD ProtoOptionsSet wireguard /NAME:PresharedKey /VALUE:$private_key
# Check
./vpncmd.sh sevpn /SERVER /CMD ProtoOptionsGet wireguard
unset private_key
```
or run
```bash
./wireguard.sh
```
Stop the server and start it in detached mode
```bash
docker stop sevpn
./start.sh -d
```

# Wireguard Settings
Create a new hub with ./vpncmd
```bash
HubCreate wireguard /PASSWORD:none
Hub wireguard
SetEnumDeny
SetMaxSession 256
SecureNatEnable
```
Create a user with your client public key
```bash
UserCreate test /GROUP:none /REALNAME:none /NOTE:none
UserSignedSet test /CN:none /SERIAL:none
WgkAdd [CLIENT PUBLIC KEY] /HUB:wireguard /USER:test
ProtoOptionsGet wireguard
```

## Client Settings
You can use any kind of Wireguard client with the following simple config file:
```bash
[Interface]
PrivateKey = [SERVER PRIVATE KEY]
Address = 192.168.30.2/24

[Peer]
PublicKey = [SERVER PUBLIC KEY]
PresharedKey = [SERVER PSK]
AllowedIPs = 192.168.30.0/24
Endpoint = [SERVER EXTERNAL IP]:5555
PersistentKeepalive = 25
```
