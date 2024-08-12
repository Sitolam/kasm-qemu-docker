#!/usr/bin/env bash
set -Eeuo pipefail

mkdir /dev/net
mknod /dev/net/tun c 10 200
chmod 0666 /dev/net/tun

NET_OPTS="-nic user,hostfwd=tcp::8888-:22"
return 0
