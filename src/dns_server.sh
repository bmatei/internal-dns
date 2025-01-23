#!/bin/bash

HOSTS="/etc/hosts"
UP_LIMIT="# EnablePrinting"
SED_LIMITS="/${UP_LIMIT}/,$"
CB="new_dhcp_event_cb.sh"
DB="/usr/share/dhcp_listener/subscribers"
CACHE="/tmp/dns_serv.hosts"

validate_sed_arg() {
	local data="$1"
	local delim="${2-/}"
	sed 's@['"$delim"'.]@\\&@g' <<< "$data"
}

delete_dns_record() {
	local host="$(validate_sed_arg $1)"
	local db="$2"
	[ -n "$host" ] && [ -f "$db" ] || return 1
	sed -i "$SED_LIMITS"' {/'"$host"'$/d}' "$db"
}

add_dns_record() {
	local host="$1"
	local ip="$2"
	local db="$3"
	[ -n "$host" ] && [ -n "$ip" ] && [ -f "$db" ] || return 1
	delete_dns_record "$host" "$db"
	echo "$ip $host" >> "$db"
}

list_dns_records() {
	awk '
	BEGIN {
		out = "["
		p = 0
	}
	(p == 1) {
		out = sprintf("%s%s", out,
			"{\"host\": \"" $2 "\", \"ip\": \"" $1 "\"},")
	}
	/# EnablePrinting/ {
		p = 1
	}
	END {
		out = substr(out, 1, length(out) - 1)
		out = sprintf("%s]", out)
		print out
	}
	' "$HOSTS"
}

enable() {
	if [ -f "$CACHE" ]; then cp $CACHE $HOSTS
	else sed -n "$SED_LIMITS"' {q1}'  "$HOSTS" && echo "$UP_LIMIT" >> "$HOSTS"; fi
	grep -q "$CB" "$DB" || dhcp_listener.sh -s "$CB"
	return 0
}

disable() {
	dhcp_listener.sh -u "$CB"
	sed -i "$SED_LIMITS"' d' "$HOSTS"
}

[ -z "$1" ] && enable && exit

case "$1" in
	-a|--add-record)
		add_dns_record "$2" "$3" "$HOSTS"
		systemctl restart dnsmasq
	;;
	-d|--delete-record)
		delete_dns_record "$2" "$HOSTS"
		systemctl restart dnsmasq
	;;
	-l|--list-records)
		list_dns_records "$HOSTS"
	;;
	-u|--uninstall)
		disable
	;;
esac
