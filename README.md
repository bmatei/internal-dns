## Description

This repository builds into a package that leverages DNSMasq and `/etc/hosts` to provide DNS capabilities for hosts inside an internal network.

It edits the `/etc/hosts` file with any new IP being allocated by `DHCP` in the network the software runs in while DNSMasq responds to requests for those hostnames.

If you have any questions feel free to ping me at busui.matei1994@gmail.com

## Build dependencies:
 * bats (https://github.com/bats-core)
 * build-rules (https://github.com/bmatei/build_rules)
