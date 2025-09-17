#!/usr/bin/env bash
#

echo 'This script may corrupt your system. No warranties are given, expressed or implied.' 1>&2

if [ $EUID -ne 0 ]; then
    echo 'You must run this script as root' 1>&2
    exit 1
fi

ACTION="$1"
NGINX_CONF_DIR="$2"

[   -z "$NGINX_CONF_DIR" ] && NGINX_CONF_DIR='/etc/nginx'
[ ! -d "$NGINX_CONF_DIR" ] && NGINX_CONF_DIR=''

if [ -z "$ACTION" ]; then
    echo "Usage: $0 <action> [install-dir]"
    [ -n "$NGINX_CONF_DIR" ] && echo "Nginx config directory: $NGINX_CONF_DIR"
    echo "Actions: install"
    exit 1
fi

if [ ! -d "$NGINX_CONF_DIR" ]; then
    echo 'Cannot find nginx directory, please halp' 1>&2
    exit 1
fi

# ---

set -e

echo '[1/4] Prepare nginx config directory...' 1>&2

pushd ./etc/nginx
for filename in *; do
    if [ -e "$NGINX_CONF_DIR/$filename" ]; then
        if [ -e "$NGINX_CONF_DIR/$filename.orig" ]; then
            echo "Error: dirty state found in [$NGINX_CONF_DIR]."
            exit 1
        fi
        if [ -f "$NGINX_CONF_DIR/$filename" ]; then
            cmp -s ./$filename $NGINX_CONF_DIR/$filename && continue
        fi
        mv -v $NGINX_CONF_DIR/$filename $NGINX_CONF_DIR/$filename.orig
    fi
done

echo '[2/4] Copy contents to nginx config directory...' 1>&2

for filename in *; do
    cp -v -r ./$filename $NGINX_CONF_DIR/$filename;
done
popd

echo '[3/4] Create directories for html content...' 1>&2

mkdir -v -p /var/www

echo '[4/4] Copy contents to [/var/www]...' 1>&2

for filename in ./var/www/*; do
    cp -v -r $filename /var/www/$filename;
done

echo 'Operation complete!' 1>&2

