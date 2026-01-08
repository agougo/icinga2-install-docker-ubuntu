#!/bin/bash

set -euo pipefail
trap 'echo "Error on line $LINENO: $BASH_COMMAND" >&2' ERR

# Setup a bunch of API Users
#echo -e "\n" >> /data/etc/icinga2/conf.d/api-users.conf
#echo "object ApiUser \"icingaweb2\" {" >> /data/etc/icinga2/conf.d/api-users.conf
#echo "  password = \"icingaweb2\" " >> /data/etc/icinga2/conf.d/api-users.conf
#echo "  permissions = [ \"status/query\", \"actions/*\", \"objects/modify/*\", \"objects/query/*\" ]" >> /data/etc/icinga2/conf.d/api-users.conf
#echo "}" >> /etc/icinga2/conf.d/api-users.conf

#echo -e "\n" >> /data/etc/icinga2/conf.d/api-users.conf
#echo "object ApiUser \"admin\" {" >> /data/etc/icinga2/conf.d/api-users.conf
#echo "  password = \"admin\" " >> /data/etc/icinga2/conf.d/api-users.conf
#echo "  permissions = [ \"*\" ]" >> /data/etc/icinga2/conf.d/api-users.conf
#echo "}" >> /data/etc/icinga2/conf.d/api-users.conf

# Create Token
#icingacli setup token create

# Configure as master
#icinga2 node wizard
#systemctl restart icinga2