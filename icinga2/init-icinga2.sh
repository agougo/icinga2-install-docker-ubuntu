#!/bin/bash

set -euo pipefail
trap 'echo "Error on line $LINENO: $BASH_COMMAND" >&2' ERR

cd ~

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

apt clean && rm -rf /var/lib/apt/lists/*

# Features enable
#icinga2 feature enable icingadb
