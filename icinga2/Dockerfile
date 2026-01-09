# Dockerfile for Icinga2
FROM ubuntu:24.04

# Metadata
LABEL org.opencontainers.image.title="Icinga2"
LABEL org.opencontainers.image.description="Icinga2 Core"
LABEL org.opencontainers.image.version="2.15.1"

# Install any additional packages you might need
# RUN apt update && apt install -y apt-transport-https && rm -rf /var/lib/apt/lists/*

# Copy custom configuration files
# COPY [Local File] [Remote File]

# Copy initialization scripts
# They will be executed automatically on first container start
COPY init-icinga2.sh /root/init-icinga2.sh
RUN chmod +x /root/init-icinga2.sh && /root/init-icinga2.sh

# Additional commands you may need
#

# Expose the standard Icinga2 port
EXPOSE 5665

#Start Service
CMD ["icinga2", "daemon", "--log-level", "information"]