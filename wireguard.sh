#!/usr/bin/env bash

DATA_DIR=${PWD}/data
VPNCMD=${PWD}/vpncmd.sh
KEY=${DATA_DIR}/wg_server.key
PSK=${DATA_DIR}/wg_psk.key

if [ ! -r ${KEY} ] ; then
  ${VPNCMD} sevpn /TOOLS /CMD:GenX25519 > ${KEY}
  private_key=$(cat ${KEY} | grep Private | cut -d " " -f 3)
  ${VPNCMD} sevpn /SERVER /CMD ProtoOptionsSet wireguard /NAME:PrivateKey /VALUE:$private_key
fi

if [ ! -r ${PSK} ] ; then
  ${VPNCMD} sevpn /TOOLS /CMD:GenX25519 > ${PSK}
  private_key=$(cat ${PSK} | grep Private | cut -d " " -f 3)
  ${VPNCMD} sevpn /SERVER /CMD ProtoOptionsSet wireguard /NAME:PresharedKey /VALUE:$private_key
fi

# Check
${VPNCMD} sevpn /SERVER /CMD ProtoOptionsGet wireguard

