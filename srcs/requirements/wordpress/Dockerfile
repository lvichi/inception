# WordPress Dockerfile
FROM debian:oldstable

# Install PHP and required dependencies
RUN apt-get update && \
    apt-get install -y php-fpm php-mysql curl unzip && \
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

# Command to run PHP-FPM in the foreground
CMD ["php-fpm7.4", "-F"]