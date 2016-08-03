#!/bin/bash

printf "This script requires the root user and will change data on your system!\n" 1>&2
read -p "Is this ok [y/N]: " PROMPT
if [ "${PROMPT}" != "Y" ] && [ "${PROMPT}" != "y" ]; then
  printf "Operation aborted.\n" 1>&2
  exit 1
fi

if [ "${EUID}" -ne 0 ]; then
  printf "Error: Not running as root.\n" 1>&2
  exit 1
fi

set -e

printf "[1/8] Installing nginx...\n"
PKGMGR="/usr/bin/dnf"
[ ! -x "${PKGMGR}" ] && PKGMGR="/usr/bin/yum"
if [ ! -x "${PKGMGR}" ]; then
  printf "Error: Cannot find system package manager.\n" 1>&2
  exit 1
fi
if [ "$(cat /etc/system-release)" == "CentOS*" ]; then
  $PKGMGR --enablerepo=epel --assumeyes install nginx
else
  $PKGMGR --assumeyes install nginx
fi

printf "[2/8] Cloning repository into the system...\n"
pushd "$(git rev-parse --show-toplevel)"
rm -Rf ./var/run
rm -Rf /etc/nginx/*
cp -a ./etc/nginx/* /etc/nginx/
cp -a ./home/nginx /home/nginx
pushd /usr/share/nginx
ln -s ../../../etc/nginx conf
ln -s ../../../etc/nginx/conf.d conf.d
ln -s ../../../var/log/nginx logs
ln -s ../../../home/nginx www
popd
popd

printf "[3/8] ...\n"
printf "[4/8] ...\n"
printf "[5/8] ...\n"
printf "[6/8] ...\n"
printf "[7/8] ...\n"
printf "[8/8] ...\n"

printf "Operation complete!\n"
