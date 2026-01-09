#!/bin/bash

set -euo pipefail
trap 'echo "Error on line $LINENO: $BASH_COMMAND" >&2' ERR

cd ~

# Get the hostname (will be 'icinga2' at runtime from docker-compose)
HOSTNAME=$(hostname)

# Install pre-requisites
apt update
apt install -y apt-transport-https wget

# Add Icinga2 Repo
wget -O icinga-archive-keyring.deb "https://packages.icinga.com/icinga-archive-keyring_latest+ubuntu$(. /etc/os-release; echo "$VERSION_ID").deb"
apt install ./icinga-archive-keyring.deb
. /etc/os-release; if [ ! -z ${UBUNTU_CODENAME+x} ]; then DIST="${UBUNTU_CODENAME}"; else DIST="$(lsb_release -c| awk '{print $2}')"; fi; echo "deb [signed-by=/usr/share/keyrings/icinga-archive-keyring.gpg] https://packages.icinga.com/ubuntu icinga-${DIST} main" > /etc/apt/sources.list.d/${DIST}-icinga.list
echo "deb-src [signed-by=/usr/share/keyrings/icinga-archive-keyring.gpg] https://packages.icinga.com/ubuntu icinga-${DIST} main" >> /etc/apt/sources.list.d/${DIST}-icinga.list
apt update

# Install Icinga2
apt install -y dialog icinga2 monitoring-plugins

# Icinga2 Master Setup Script

# Create required directories
mkdir -p /run/icinga2
chown nagios:nagios /run/icinga2

# Setup API
icinga2 api setup

# Configure zones
cat > /etc/icinga2/zones.conf <<EOF
object Endpoint "$HOSTNAME" {
}

object Zone "master" {
  endpoints = [ "$HOSTNAME" ]
}

object Zone "global-templates" {
  global = true
}

object Zone "director-global" {
  global = true
}
EOF

# Configure API
cat > /etc/icinga2/features-available/api.conf <<EOF
object ApiListener "api" {
  accept_commands = true
  accept_config = true
}
EOF

# Setup a bunch of API Users
echo -e "\n" >> /etc/icinga2/conf.d/api-users.conf
echo "object ApiUser \"icingaweb2\" {" >> /etc/icinga2/conf.d/api-users.conf
echo "  password = \"icingaweb2\" " >> /etc/icinga2/conf.d/api-users.conf
echo "  permissions = [ \"status/query\", \"actions/*\", \"objects/modify/*\", \"objects/query/*\" ]" >> /etc/icinga2/conf.d/api-users.conf
echo "}" >> /etc/icinga2/conf.d/api-users.conf

echo -e "\n" >> /etc/icinga2/conf.d/api-users.conf
echo "object ApiUser \"admin\" {" >> /etc/icinga2/conf.d/api-users.conf
echo "  password = \"admin\" " >> /etc/icinga2/conf.d/api-users.conf
echo "  permissions = [ \"*\" ]" >> /etc/icinga2/conf.d/api-users.conf
echo "}" >> /etc/icinga2/conf.d/api-users.conf

# Stop the service
#pkill icinga2
#icinga2 daemon --log-level information

# Create Directories
mkdir -p /etc/icinga2 /var/lib/icinga2 /var/log/icinga2 /var/cache/icinga2 /var/spool/icinga2
chown -R nagios:nagios /etc/icinga2 /var/lib/icinga2 /var/log/icinga2 /var/cache/icinga2 /var/spool/icinga2

# Features enable
#icinga2 feature enable icingadb
