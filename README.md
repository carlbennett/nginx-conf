# Nginx Configuration
## Summary
This is a fully developed Nginx configuration ready for deployment in
production environments. It is pre-configured to be scalable, efficient, secure,
and reliable.

![Nginx 1.13.0](https://img.shields.io/badge/nginx-1.13.0-green.svg)
[![LICENSE](https://img.shields.io/github/license/carlbennett/nginx-conf.svg)](./LICENSE.txt)

### Author's Notes
[@carlbennett](https://github.com/carlbennett) wanted an Nginx configuration
that was both secure and modular enough that it could be put on any server,
with minor tuning to just a few settings to make it work anywhere. And thus,
this configuration was created.

It is based on the Fedora 29 x86\_64 Nginx packages and is maintained at
[carlbennett/nginx-conf](https://github.com/carlbennett/nginx-conf). It
is compatible with most Nginx installations, and works well on CentOS 7 when
using [nginx.org's repos](http://nginx.org/en/linux_packages.html) instead of
the default centos repos.

Recommended Nginx version: `1.13.0` or newer.

## Features
- Global caching
  - If included, tunes nginx to have browsers cache static resources.
- Global Gzip compression
  - If included, common types of static resources will be compressed by nginx.
- Global URL filtering
  - If included, nginx will disconnect common types of attacks based on the
    URL, instead of responding with an error page or content which could alert
    the bad actor about your server, which would send an invite to come back
    later.
  - Can be extended upon very easily to block even more types of URLs.
- PHP support
  - If included, you can _and should_ define php error reporting and short tags
    in your server block.
  - You can pass other php options via the PHP\_VALUE parameter too.

## Installation
These steps have been tested on Fedora 29 x86\_64, and may require minor
changes to work on non-RHEL systems.

The following commands assume you are logged in as `root` or are `sudo`ing as
`root` before every command.

### Install nginx
:warning: If you are using CentOS, substitute `dnf` with `yum` in the command
below.

```sh
dnf install nginx
```

### Setup the user and group
If you wish to replace apache:
```sh
userdel -r apache
usermod -u 48 nginx
groupmod -g 48 nginx
```

Add permission group for web content:
```
groupadd -r www-data
usermod -aG www-data nginx
usermod -aG www-data `whoami`
```

### Clone this repository
```sh
cd ~
git clone git@github.com:carlbennett/nginx-conf.git && cd ./nginx-conf
```

### Copy files to system
```sh
cp -r ./etc/nginx/ /etc/nginx
mkdir -p /var/www && cp -r ./var/www/* /var/www
```

### File and directory permissions
```sh
chown -R root:root /etc/nginx
chown -R nginx:www-data /var/www
find /var/www -type f -print0 | sudo xargs -0 chmod 664
find /var/www -type d -print0 | sudo xargs -0 chmod 775
```

### SELinux permissions
This is only necessary if using a different directory than `/var/www`. On
RHEL-like systems with SELinux, `/var/www` is already configured properly.

```sh
dnf install policycoreutils-python-utils
semanage fcontext -a -t httpd_sys_content_t '/opt/other-www(/.*)?'
restorecon -r /opt/other-www
```

### SELinux booleans
If using nginx on a RHEL-like system with a backend like php-fpm, the following
booleans become useful to enable network connectivity as the nginx/php-fpm user.

```sh
setsebool -P httpd_can_network_connect 1
setsebool -P httpd_can_network_connect_db 1
setsebool -P httpd_can_network_memcache 1
```

### Configure nginx
You should now configure everything under `/etc/nginx` to your liking.

### Run nginx
```sh
systemctl enable nginx
systemctl start nginx
```
