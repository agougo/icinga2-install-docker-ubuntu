# Dockerfile for Icinga2
FROM icinga/icinga2:2.15.1

# Metadata
LABEL org.opencontainers.image.title="Icinga2"
LABEL org.opencontainers.image.description="Icinga2 Core"
LABEL org.opencontainers.image.version="2.15.1"

# Environment variables (override at runtime with -e or docker-compose if needed)
#ENV ICINGA_CN=icinga2
#ENV ICINGA_MASTER=1
#ENV ICINGA_ACCEPT_COMMANDS=1
#ENV ICINGA_ACCEPT_CONFIG=1
#ENV ICINGA_DISABLE_CONFD=0
#ENV ICINGA_ENDPOINT=icinga2,172.31.0.2,5665
#ENV ICINGA_GLOBAL_ZONES=global-config
#ENV ICINGA_LISTEN=5665
#ENV ICINGA_ZONE=master
#ENV ICINGA_TICKET=0123456789

# Install any additional packages you might need
RUN apt update && apt install -y apt-transport-https dialog monitoring-plugins icingacli && rm -rf /var/lib/apt/lists/*

# Copy custom configuration files
# COPY [Local File] [Remote File]

# Copy initialization scripts
# They will be executed automatically on first container start
COPY init-icinga2.sh /data-init/init-icinga2.sh
RUN chmod +x /data-init/init-icinga2.sh

# Additional commands you may need

# Expose the standard Icinga2 port
EXPOSE 5665