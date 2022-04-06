#!/bin/sh
​
host_ip=$(ping -c 1 host.docker.internal 2>&1 | grep PING | awk '{print $3}' | tr -d '():')
echo "Adding $host_ip to /etc/hosts as alias for devbox"
echo "${host_ip} devbox.library.northwestern.edu" >> /etc/hosts
cmd="/bin/prometheus $@"
echo "Dropping privileges and running ${cmd}"
exec su -ls /bin/sh nobody -c "$cmd" 