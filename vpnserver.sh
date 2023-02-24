## start_vpn_server.sh
#!/bin/bash

SERVER_HOST=localhost
SERVER_PORT=5555

if [ ! -f /.dockerenv ]; then
  echo "This script should run under Docker"
  exit 1
fi

echo -n "Whoami: "
whoami

vpncmd ${SERVER_HOST}:${SERVER_PORT} /SERVER &> /dev/null
if [ $? -gt 0 ]; then
    vpnserver start
    sleep 2
fi

ss -a | grep ${SERVER_PORT} &> /dev/null
if [ $? -gt 0 ]; then
    echo "VPN Server failed to start"
    exit 1
fi

echo "VPN Server Started"
tail -f /usr/local/libexec/softether/vpnserver/server_log/vpn_*.log
