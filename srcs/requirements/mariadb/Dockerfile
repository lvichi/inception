# Mariadb Dockerfile
FROM debian:oldstable

# Install MariaDB
RUN apt-get update && \
    apt-get install -y gettext-base mariadb-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld

# Copy the initialization script
COPY tools/start.sh /usr/local/bin/start.sh

# Set the script to be executable
RUN chmod +x /usr/local/bin/start.sh

ENTRYPOINT ["start.sh"]