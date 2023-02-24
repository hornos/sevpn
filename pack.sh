#!/usr/bin/env bash

DATA_DIR=${PWD}/data

echo -n "Creating sevpn_amd64.tgz: "
docker save sevpn:amd64 | gzip > sevpn_amd64.tgz
echo "done"

echo -n "Creating sevpn_support.tgz: "
tar czf sevpn_support.tgz \
  admin_password.sh \
  init.txt \
  login.sh \
  start_docker.sh \
  vpncmd.sh \
  vpnserver.sh \
  wireguard.sh
echo "done"
