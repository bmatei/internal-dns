#!/bin/bash

host="$1"
ip="$2"
[ -z "$host" ] || [ -z "$ip" ] && exit

LOCK=/tmp/aware-dns-server-lock

while ! mkdir $LOCK  2>/dev/null; do sleep 0.01; done
sed -i '/# EnablePrinting/,$ {/'"$host".aici'/d}' /etc/hosts
echo "$ip $host.aici # $(date '+%H:%M:%S-%d-%m-%y')" >> /etc/hosts
systemctl restart dnsmasq
cat /etc/hosts > /tmp/dns_serv.hosts
rmdir $LOCK
