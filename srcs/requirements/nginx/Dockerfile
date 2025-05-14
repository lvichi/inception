# Nginx Dockerfile
FROM debian:oldstable

# Install Nginx and OpenSSL
RUN apt-get update && \
    apt-get install -y nginx openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create SSL cert and key
RUN mkdir -p /etc/nginx/ssl/ && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout /etc/nginx/ssl/cert.key \
      -out /etc/nginx/ssl/cert.crt \
      -subj "/C=PT/ST=Porto/L=Porto/O=42Inception/OU=Dev/CN=lvichi.42.fr"

# Command to run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
