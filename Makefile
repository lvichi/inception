include srcs/.env

all: up

build:
	@docker compose -f $(COMPOSE_PATH) build --no-cache

up: data
	@docker compose -f $(COMPOSE_PATH) up -d
	@docker ps -a
	@docker volume ls
	@docker network ls

debug: data
	@docker compose -f $(COMPOSE_PATH) up

stop:
	@docker compose -f $(COMPOSE_PATH) down --remove-orphans --volumes

restart: stop up

restart_debug: stop debug

fclean_restart: fclean up

clean: stop
	@docker image rm $(COMPOSE_PROJECT_NAME)-nginx $(COMPOSE_PROJECT_NAME)-wordpress $(COMPOSE_PROJECT_NAME)-mariadb || true

data:
	@mkdir -p $(DATA_PATH)/mariadb $(DATA_PATH)/wordpress

data_clean:
	@sudo -n true 2>/dev/null || { \
		echo "❌ You must have sudo privileges to run this command."; \
		exit 1; \
	}
	@sudo rm -rf $(DATA_PATH)/mariadb $(DATA_PATH)/wordpress

fclean: clean data_clean

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