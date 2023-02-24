#!/usr/bin/env bash

NAME=sevpn
NETWORK=sevpn
SERVER_DIR=/usr/local/libexec/softether/vpnserver/
DATA_DIR=${PWD}/data
IMAGE=sevpn:amd64
COMMAND="/bin/bash -c /vpnserver.sh"

OPTS="-it --rm"
while getopts 'dn:x:h' opt; do
  case "$opt" in
    n)
      NAME="$OPTARG"
      ;;
    x)
      NETWORK="$OPTARG"
      ;;

    d)
      echo "Starting in detached mode"
      OPTS="-d --restart unless-stopped"
      ;;
   
    ?|h)
      echo "Usage: $(basename $0) [-n name]"
      exit 1
      ;;
  esac
done
shift "$(($OPTIND -1))"

# Start the container if it is stopped
status=$(docker inspect ${NAME} | jq .[]."State"."Status")
if [ $status = "\"running\"" ] ; then 
    docker start ${NAME}
    exit $?
fi

# Initial start
for i in packet_log security_log server_log backup.vpn_server.config ; do
  if [ ! -d ${DATA_DIR}/${i} ] ; then
    mkdir -p ${DATA_DIR}/${i}
  fi
done

if [ ! -r ${DATA_DIR}/adminip.txt ] ; then
  cat <<EOF > ${DATA_DIR}/adminip.txt
127.0.0.1
::1
172.17.0.1
EOF
fi

if [ ! -r ${DATA_DIR}/vpn_server.config ] ; then
  touch ${DATA_DIR}/vpn_server.config
fi

docker run \
  $OPTS \
  --name $NAME \
  -p=5555:5555 \
  -p=5555:5555/udp \
  -m 256m \
  --cpu-shares 512 \
  --mount type=bind,src=${DATA_DIR}/vpn_server.config,dst=${SERVER_DIR}/vpn_server.config \
  --mount type=bind,src=${DATA_DIR}/adminip.txt,dst=${SERVER_DIR}/adminip.txt,readonly \
  --mount type=bind,src=${DATA_DIR}/server_log,dst=${SERVER_DIR}/server_log \
  --mount type=bind,src=${DATA_DIR}/packet_log,dst=${SERVER_DIR}/packet_log \
  --mount type=bind,src=${DATA_DIR}/security_log,dst=${SERVER_DIR}/security_log \
  --mount type=bind,src=${DATA_DIR}/backup.vpn_server.config,dst=${SERVER_DIR}/backup.vpn_server.config \
  --mount type=bind,src=${PWD}/init.txt,dst=/init.txt,readonly \
  --mount type=bind,src=${PWD}/vpnserver.sh,dst=/vpnserver.sh,readonly \
  --entrypoint "" \
  --network=$NETWORK \
  $IMAGE $COMMAND
