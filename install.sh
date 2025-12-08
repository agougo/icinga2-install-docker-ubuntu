#!/bin/bash

# Load OS info
. /etc/os-release

if [[ "$ID" == "ubuntu" && "$VERSION_ID" == "24.04" ]]; then
    echo "Running on Ubuntu 24.04. Proceeding..."

set -euo pipefail
trap 'echo "Error on line $LINENO: $BASH_COMMAND" >&2' ERR

# Setup Firewall
# Check if ufw is installed
if ! dpkg -l | grep -qw ufw; then
    echo "Firewall not installed. Proceeding with the script..."

    # Your actual script goes here
    apt install ufw -y
    echo "y" | ufw enable
    ufw status

else
    echo "Firewall is installed. Exiting."
fi

# Set firewall rules
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 3000/tcp
ufw allow 5665/tcp

# Download and run Docker's convenience script
apt update
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh
systemctl enable docker.service
systemctl enable containerd.service

# Add stuff here

docker compose up -d

# Add DNS entry
#IP=$(hostname -I)
#echo $IP $HOSTNAME >> /etc/hosts

else
    echo "This script only runs on Ubuntu 24.04. Exiting."
    exit 1
fi

