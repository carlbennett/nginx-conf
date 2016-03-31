# Nginx Configuration
## Preface
[@carlbennett](https://github.com/carlbennett) wanted an nginx configuration
that was both secure and modular enough that he could put it on any server and
tune just a few small settings to make it work anywhere.

And thus, this configuration was born.

It is based off of the Fedora 21 x86_64 nginx package and has been maintained
ever since.

Recommended Nginx version: `1.8.0` or newer.

## Features
- Global caching
 - If included, tunes nginx to have browsers cache static resources.
- Global Gzip compression
 - If included, common types of static resources will be compressed by nginx.
- Global URL filtering
 - If included, nginx will disconnect common types of attacks based on the URL,
   instead of responding with an error page or content which could alert the
   bad actor about your server, which would send an invite to come back later.
 - Can be extended upon very easily to block even more types of URLs.
- PHP support
 - If included, you can _and should_ define php error reporting and short tags
   in your server block.
- New Relic support
 - You can _and should_ define the application name for New Relic in your
   server block.

## Installation
These steps have been tested on Fedora 21 x86_64, and may require minor changes
to work on non-RHEL systems.

1. Install nginx with your package manager, such as `yum install nginx`.
2. Clone the repository somewhere on your server, such as your home directory.
3. Delete the `var/run/nginx.pid` file, it's useless while your nginx server
   isn't running.
4. The root of this repository is designed to mimic the root of Linux servers,
   you should *merge* these directories with the directories on the root of
   your server.
 - There are symbolic links in the `usr/share/nginx` directory that you should
   be mindful of.
5. Create a new unix system group named `www-data`.
6. If you don't use apache, remap nginx to use apache's user and group ids
   (because we hate apache here).
 - `usermod -u 48 nginx && groupmod -g 48 nginx`
6. Run `chown nginx:www-data /home/nginx`.
7. Run `find /home/nginx/ -type f -print0 | sudo xargs -0 chmod 664`
8. Run `find /home/nginx/ -type d -print0 | sudo xargs -0 chmod 775`
9. Edit the config files in the `etc/nginx` directory to your liking.
10. At this point, you should probably fix any SELinux policies, or put SELinux
    in permissive mode. Nginx will fail to start in this way if you don't.
11. Run nginx with your service manager, such as `service nginx start`.
