ifneq ("$(wildcard srcs/.env)", "")
	include srcs/.env
	export
endif

ENV_LIST := \
	DOMAIN_NAME \
	COMPOSE_PATH \
	DATA_PATH \
	COMPOSE_PROJECT_NAME \
	SECRET_DIR \
	SECRET_FILES \
	DB_HOST \
	DB_USER \
	DB_NAME \
	WP_ADMIN \
	WP_ADMIN_EMAIL \
	WP_USER \
	WP_USER_EMAIL

# Validate that all required env variables are set and non-empty
$(foreach var,$(ENV_LIST), $(if $(value $(var)),,$(error Missing or empty environment variable: $(var))))

DATA_PATH := $(shell eval echo $(DATA_PATH))

IMAGES := $(shell yq '.services[].image' $(COMPOSE_PATH) 2>/dev/null)

all: up

up: precheck data set-host
	@docker compose -f $(COMPOSE_PATH) up -d
	@docker ps -a
	@docker volume ls
	@docker network ls

up_build: build up

build: precheck
	@docker compose -f $(COMPOSE_PATH) build --no-cache

debug: up logs

logs: precheck
	@docker compose -f $(COMPOSE_PATH) logs -f --tail=100

stop: precheck
	@docker compose -f $(COMPOSE_PATH) down --remove-orphans --volumes

restart: stop up

restart_debug: stop debug

restart_fclean: fclean up

data_clean:
	@if [ -d $(DATA_PATH) ]; then \
		$(call CHECK_SUDO); \
		echo "📁❌ Removing data directory: $(DATA_PATH)"; \
		sudo rm -rf $(DATA_PATH); \
	fi

clean: stop
	@for image in $(IMAGES); do \
		if docker image inspect $$image >/dev/null 2>&1; then \
			docker image rm $$image; \
		fi; \
	done

fclean: unset-host clean data_clean
	@docker builder prune -f

## HELPERS
# Create required local data directories
data:
	@for path in $(shell yq '.volumes[].driver_opts.device' $(COMPOSE_PATH)); do \
		expanded_path=$$(eval echo $$path); \
		if [ ! -d "$$expanded_path" ]; then \
			echo "📁 Creating $$expanded_path"; \
			mkdir -p "$$expanded_path"; \
		fi; \
	done

# Check if the user has sudo privileges
define CHECK_SUDO
  sudo -n true 2>/dev/null || { \
    echo "❌ You must have sudo privileges to run this command."; \
    exit 1; \
  }
endef

# Add the domain name to /etc/hosts if it doesn't exist
set-host:
	@grep -q "$(DOMAIN_NAME)" /etc/hosts || { \
		$(call CHECK_SUDO); \
		sudo sh -c 'echo "127.0.0.1 $(DOMAIN_NAME)" >> /etc/hosts'; \
		echo "✅ Added $(DOMAIN_NAME) to /etc/hosts"; \
	}

unset-host:
	@if grep -q "$(DOMAIN_NAME)" /etc/hosts; then \
		$(call CHECK_SUDO); \
		sudo sed -i "/$(DOMAIN_NAME)/d" /etc/hosts; \
		echo "❌ Removed $(DOMAIN_NAME) from /etc/hosts"; \
	fi

# Check if all tools are installed
precheck_tools:
	@missing=0; \
	for tool in $(REQUIRED_TOOLS); do \
		if ! command -v $$tool >/dev/null 2>&1; then \
			echo "❌ Missing required tool: $$tool"; \
			missing=1; \
		fi; \
	done; \
	[ $$missing -eq 0 ]

# Check that secrets directory exists and each file is non‐empty
precheck_secrets:
	@if [ ! -d "$(SECRET_DIR)" ]; then \
		echo "❌ Missing secrets directory: $(SECRET_DIR)"; \
		exit 1; \
	fi; \
	missing=0; \
	for f in $(SECRET_FILES); do \
		if [ ! -s "$(SECRET_DIR)/$$f" ]; then \
			echo "❌ Missing or empty secret file: $(SECRET_DIR)/$$f"; \
			missing=1; \
		fi; \
	done; \
	[ $$missing -eq 0 ]

precheck: precheck_tools precheck_secrets

help:
	@echo "Makefile Commands:"
	@echo "  up              : Start containers in detached mode"
	@echo "  up_build        : Rebuild images and start containers"
	@echo "  build           : Rebuild all images without cache"
	@echo "  debug           : Start containers (via 'up') and follow logs"
	@echo "  logs            : Follow logs of running containers"
	@echo "  stop            : Stop and remove all containers, volumes, and orphans"
	@echo "  restart         : Stop and start containers again"
	@echo "  restart_debug   : Stop and start, then follow logs"
	@echo "  restart_fclean  : Full cleanup and start fresh"
	@echo "  clean           : Remove built images only"
	@echo "  fclean          : Remove images and all persistent data (requires sudo)"
	@echo "  data_clean      : Remove persistent data (requires sudo)"
	@echo "  help            : Show this help message"

.PHONY: all up build debug logs stop restart restart_debug restart_fclean \
	data_clean clean fclean data set-host precheck help