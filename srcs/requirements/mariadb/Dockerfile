# Mariadb Dockerfile
FROM debian:oldstable

# Install MariaDB
RUN apt-get update && \
    apt-get install -y mariadb-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld

# Command to run MariaDB in the foreground
CMD ["mysqld"]
