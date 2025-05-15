# WordPress Dockerfile
FROM debian:oldstable

# Install PHP and required dependencies
RUN apt-get update && \
    apt-get install -y php-fpm php-mysql curl unzip default-mysql-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /run/php

# Install WordPress
RUN curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    mkdir -p /var/www/html && \
    mv wordpress/* /var/www/html && \
    rm -rf latest.tar.gz wordpress /var/www/html/wp-config.php

# Set up PHP-FPM permissions
RUN chown -R www-data:www-data /var/www/html && \
    addgroup --gid 984 configgroup && \
    usermod -aG configgroup www-data

# Install wp-cli to manage WordPress from the command line
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Copy the initialization script
COPY tools/start.sh /usr/local/bin/start.sh

# Set the script to be executable
RUN chmod +x /usr/local/bin/start.sh

ENTRYPOINT ["start.sh"]
