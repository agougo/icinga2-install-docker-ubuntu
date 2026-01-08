# Dockerfile for PostgreSQL 17 (official + best practices)
FROM postgres:17

# Metadata
#LABEL maintainer="your-name@company.com"
LABEL org.opencontainers.image.title="PostgreSQL 17"
LABEL org.opencontainers.image.description="PostgreSQL 17 for Icinga2"
LABEL org.opencontainers.image.version="17"

# Environment variables (override at runtime with -e or docker-compose if needed)
ENV POSTGRES_INITDB_ARGS="--locale=C.UTF-8 --encoding=UTF8"
ENV PGDATA=/var/lib/postgresql/data/

# Optional: set a default database/user/password and change the default postgres pass
# ENV POSTGRES_DB=mydb
# ENV POSTGRES_USER=myuser
ENV POSTGRES_PASSWORD=postgres

# Install any additional packages you might need
# RUN apt-get update && apt-get install -y postgresql-contrib && rm -rf /var/lib/apt/lists/*

# Copy custom configuration files
COPY pg_hba.conf /etc/postgresql/pg_hba.conf

# Copy initialization scripts (SQL + shell scripts in /docker-entrypoint-initdb.d/)
# They will be executed automatically on first container start
COPY init-icinga2-postgresql.sh /docker-entrypoint-initdb.d/init-icinga2-postgresql.sh
RUN chmod +x /docker-entrypoint-initdb.d/init-icinga2-postgresql.sh

# Expose the standard PostgreSQL port
EXPOSE 5432