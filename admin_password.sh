#!/usr/bin/env bash

DATA_DIR=${PWD}/data
VPNCMD=${PWD}/vpncmd.sh

pass=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
${VPNCMD} sevpn /SERVER /CMD ServerPasswordSet $pass
echo $pass > ${DATA_DIR}/admin.txt
