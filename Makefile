COMPOSE_PATH = srcs/docker-compose.yml

all: up

build:
	@COMPOSE_BAKE=true docker compose -f $(COMPOSE_PATH) build --no-cache

up:
	@docker compose -f $(COMPOSE_PATH) up -d
	@docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

debug:
	@docker compose -f $(COMPOSE_PATH) up

stop:
	@docker compose -f $(COMPOSE_PATH) down -v --remove-orphans

restart: stop up

restart_debug: stop debug

clean:
	@docker image rm srcs-nginx srcs-wordpress srcs-mariadb || true

help:
	@echo "Makefile commands:"
	@echo "  all        : Build and start the containers"
	@echo "  build      : Build the containers without cache"
	@echo "  up         : Start the containers"
	@echo "  stop       : Stop and remove the containers"
	@echo "  restart    : Restart the containers"
	@echo "  clean      : Remove images"
	@echo "  help       : Show this help message"

.PHONY: run stop restart clean help