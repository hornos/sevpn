#!/usr/bin/env bash
NAME=${1:-sevpn}
docker exec -it $NAME /bin/bash
