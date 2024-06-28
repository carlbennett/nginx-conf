
# Nginx Configuration
## Summary
This repository contains a robust and ready-to-deploy Nginx configuration, ideal for production environments. It is designed to be scalable, efficient, secure, and reliable.

![Nginx 1.13.0+](https://img.shields.io/badge/nginx-1.13.0%2b-green.svg)
[![LICENSE](https://img.shields.io/github/license/carlbennett/nginx-conf.svg)](./LICENSE.txt)

### Author's Notes
Created by [@carlbennett](https://github.com/carlbennett), this Nginx configuration aims to be both secure and modular, allowing easy deployment across various servers with minimal adjustments.

Based on Fedora 29 x86_64 Nginx packages, this configuration is maintained at [carlbennett/nginx-conf](https://github.com/carlbennett/nginx-conf). It is compatible with most Nginx installations and works well on enterprise Linux distributions when using [nginx.org's repositories](http://nginx.org/en/linux_packages.html).

**Recommended Nginx version:** `1.13.0` or newer.

## Features
- **Global Caching**
  - Configures Nginx to cache static resources in browsers, enhancing performance.
- **Global Gzip Compression**
  - Compresses common static resources to reduce bandwidth usage.
- **Global URL Filtering**
  - Blocks common types of attacks based on URL patterns, preventing potential security breaches.
  - Easily extendable to block additional URLs.
- **PHP Support**
  - Define PHP error reporting and short tags within your server block.
  - Pass additional PHP options using the `PHP_VALUE` parameter.

## Installation
These steps have been tested on Fedora 29 x86_64 and newer versions. Minor adjustments may be needed for non-RHEL systems.

Ensure you are logged in as `root` or using `sudo` for the commands below.

### Install Nginx
```sh
dnf install nginx
```
Tip: Swap `dnf` with `yum` if using an older distribution release.

### Setup the User and Group (Optional)
It is **optional** to remove the Apache user, the Apache and Nginx users can co-exist.

During package resolution, it used to be the case (or may still be) that the vendor Nginx packages pull in Apache-dependent packages, which create the Apache user/group, and therefore the author sees this as dirty if the system is intended to be purely Nginx without Apache whatsoever.

Be sure that the services are stopped first, no processes using these users should be running:
```sh
systemctl stop httpd.service
systemctl stop nginx.service
```

To remove Apache and take its ID number:
```sh
userdel -r apache
usermod -u 48 nginx
groupmod -g 48 nginx
```

Add custom permission group for web content, then add `nginx` and yourself to it:
```sh
groupadd -r www-data
usermod -aG www-data nginx
usermod -aG www-data `whoami`
```

### Clone the Repository
```sh
cd ~
git clone git@github.com:carlbennett/nginx-conf.git && cd ./nginx-conf
```

### Copy Files to the System
```sh
cp -r ./etc/nginx/ /etc/nginx
mkdir -p /var/www && cp -r ./var/www/* /var/www
```

### Set File and Directory Permissions
```sh
chown -v -R root:root /etc/nginx
chown -v -R nginx:www-data /var/www
find /var/www -type f -exec chmod -v 0664 {} \;
find /var/www -type d -exec chmod -v 0775 {} \;
```

### Configure SELinux Booleans
If using Nginx on a RHEL-like system with a backend like php-fpm, enable the following SELinux booleans for network connectivity:
```sh
setsebool -P httpd_can_network_connect 1
setsebool -P httpd_can_network_connect_db 1
setsebool -P httpd_can_network_memcache 1
```

### Configure SELinux File Context
For an alternate webroot, configure the SELinux file context:
```sh
dnf install policycoreutils-python-utils # provides semanage
semanage fcontext -a -t httpd_sys_content_t '/opt/other-www(/.*)?'
restorecon -r /opt/other-www
```

For directories requiring write access, use the `httpd_rw_sys_content_t` file context. For CGI/executable files, use `httpd_sys_script_exec_t`.

List all configured file contexts:
```sh
semanage fcontext -l | grep httpd
```

### Configure Nginx
Customize the configuration under `/etc/nginx` as needed.

### Run Nginx
Enable and start Nginx:
```sh
systemctl enable --now nginx.service
```
