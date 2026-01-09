#!/bin/bash

set -euo pipefail
trap 'echo "Error on line $LINENO: $BASH_COMMAND" >&2' ERR

# Setup the API and configure the Core module as a master endpoint

HOSTNAME=$(hostname)
mkdir -p /run/icinga2
chown nagios:nagios /run/icinga2

if [ ! -f /var/lib/icinga2/.initialized ]; then
    icinga2 api setup

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

    cat > /etc/icinga2/features-available/api.conf <<EOF
object ApiListener "api" {
  accept_commands = true
  accept_config = true
}
EOF

    cat >> /etc/icinga2/conf.d/api-users.conf <<EOF

object ApiUser "admin" {
  password = "admin"
  permissions = [ "*" ]
}

object ApiUser "icingaweb2" {
  password = "icingaweb2"
  permissions = [ "status/query", "actions/*", "objects/modify/*", "objects/query/*" ]
}
EOF

    touch /var/lib/icinga2/.initialized
fi