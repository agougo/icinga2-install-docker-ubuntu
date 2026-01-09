# Dockerfile for Icinga2
FROM ubuntu:24.04

# Metadata
LABEL org.opencontainers.image.title="Icinga2"
LABEL org.opencontainers.image.description="Icinga2 Core"
LABEL org.opencontainers.image.version="2.15.1"

# Copy custom configuration files
# COPY [Local File] [Remote File]

# Copy initialization scripts
# They will be executed automatically on first container start
COPY init-icinga2.sh /root/init-icinga2.sh
RUN chmod +x /root/init-icinga2.sh && /root/init-icinga2.sh

COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

# Expose the standard Icinga2 port
EXPOSE 5665

# Setup the API and configure as MASTER
ENTRYPOINT ["/root/entrypoint.sh"]