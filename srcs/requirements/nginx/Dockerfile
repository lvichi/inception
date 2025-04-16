# Nginx Dockerfile
FROM debian:oldstable

# Install Nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Command to run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
