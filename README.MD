# Inception WordPress Dockerized Project  
A complete Docker-based deployment of a WordPress site with Nginx reverse proxy and MariaDB, orchestrated via a Makefile and Docker Compose. Designed for local development and easy reproducible setups.

---

## Table of Contents

1. [Project Overview](#project-overview)  
2. [Features](#features)  
3. [Prerequisites](#prerequisites)  
4. [Environment Configuration](#environment-configuration)  
5. [Directory Structure](#directory-structure)  
6. [Getting Started](#getting-started)  
    - [1. Clone the Repository](#1-clone-the-repository)  
    - [2. Populate Secrets](#2-populate-secrets)  
    - [3. Configure Environment Variables](#3-configure-environment-variables)  
    - [4. Build & Launch](#4-build--launch)  
7. [Makefile Commands](#makefile-commands)  
8. [Docker Compose Details](#docker-compose-details)  
9. [Data Persistence & Volumes](#data-persistence--volumes)  
10. [Custom Configuration](#custom-configuration)  
11. [Troubleshooting](#troubleshooting)  
12. [Contributing](#contributing)  
13. [License](#license)  

---

## Project Overview

This project, codenamed **Inception**, provides a turn-key Docker environment for running a production-like WordPress site on your local machine. It includes:

- **Nginx** as a secure HTTPS reverse proxy  
- **WordPress** with pre-configured PHP-FPM  
- **MariaDB** as the database engine  
- **Bind-mounted volumes** for persistence of uploads and database data  
- A **Makefile** to simplify common workflows (build, up, logs, clean, etc.)  

---

## Features

- 🔒 **HTTPS-enabled** (via SSL certs that you can inject)  
- 🔄 **Automated service startup/shutdown**  
- 📂 **Persistent storage** in host directories  
- 🔧 **Configurable** via `.env` file & environment variables  
- 🛠 **Helper scripts** for directory creation and host-file management  
- 🚨 **Health checks** via Docker’s `depends_on` and restart policies  

---

## Prerequisites

- **Operating System:** Linux or macOS (sudo privileges required for host-file edits)  
- **Docker Engine:** ≥ 20.10  
- **Docker Compose:** (bundled with Docker Desktop or standalone ≥ 1.29)  
- **yq:** YAML processor (`command -v yq`)  
- **Make:** GNU Make  
- **sudo** access (to bind `/etc/hosts` entries & remove protected volumes)  

---

## Environment Configuration

1. Copy the sample environment file (if provided) or create `srcs/.env` in your working directory.  
2. Provide values for the following variables:

   ```bash
   DOMAIN_NAME=<your-domain.local>  
   COMPOSE_PATH=srcs/docker-compose.yml  
   DATA_PATH=/absolute/path/to/data  
   COMPOSE_PROJECT_NAME=inception  
   SECRET_DIR=./secrets  
   SECRET_FILES=db_password.txt db_root_password.txt wp_admin_password.txt wp_user_password.txt  
   DB_HOST=mariadb  
   DB_USER=wp_user  
   DB_NAME=wordpress  
   WP_ADMIN=<admin_username>  
   WP_ADMIN_EMAIL=<admin_email>  
   WP_USER=<wp_username>  
   WP_USER_EMAIL=<wp_user_email>  
   ```

3. Ensure each `SECRET_FILES` entry exists in `SECRET_DIR` and is non-empty.

---

## Directory Structure

```
.
├── Makefile
├── README.md                    # ← this file
├── secrets/                     # secret passwords (gitignored)
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs/
    ├── docker-compose.yml       # main Compose definition
    ├── .env                     # environment overrides
    ├── requirements/
    │   ├── mariadb/
    │   │   ├── conf/
    │   │   │   ├── init.sql
    │   │   │   └── my.cnf
    │   │   ├── Dockerfile
    │   │   └── tools/start.sh
    │   ├── nginx/
    │   │   ├── conf/nginx.conf
    │   │   └── Dockerfile
    │   └── wordpress/
    │       ├── conf/
    │       │   ├── php-fpm.conf
    │       │   ├── wp-config.php
    │       │   └── www.conf
    │       ├── Dockerfile
    │       └── tools/start.sh
```

---

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/inception.git
cd inception
```

### 2. Populate Secrets

Create the `secrets` directory and add the following files (each containing a strong password):

```bash
mkdir secrets
echo "your_db_password"          > secrets/db_password.txt
echo "your_db_root_password"     > secrets/db_root_password.txt
echo "your_wp_admin_password"    > secrets/wp_admin_password.txt
echo "your_wp_user_password"     > secrets/wp_user_password.txt
```

### 3. Configure Environment Variables

Copy or create `.env` under `srcs/` and set the required variables as shown in [Environment Configuration](#environment-configuration).

### 4. Build & Launch

```bash
# Build all images and spin up the stack
make up_build

# Follow logs
make logs
```

Access your site at `https://<DOMAIN_NAME>` (e.g. `https://lvichi.42.fr`).

---

## Makefile Commands

| Command           | Description                                                      |
|-------------------|------------------------------------------------------------------|
| `make up`         | Start services in detached mode                                  |
| `make build`      | Build (no cache) only                                            |
| `make up_build`   | Build and then start services                                    |
| `make debug`      | Start services & follow logs                                      |
| `make logs`       | Attach to logs for all services                                  |
| `make stop`       | Stop and remove containers, networks, volumes                    |
| `make clean`      | Remove images for all services                                   |
| `make fclean`     | Full clean: remove images, volumes, data (requires sudo)         |
| `make data_clean` | Delete host-mounted data directory (requires sudo)               |
| `make restart`    | `stop` + `up`                                                    |
| `make restart_debug` | `stop` + `debug`                                             |
| `make restart_fclean` | `fclean` + `up`                                            |

---

## Docker Compose Details

- **Version:** Extension v3 syntax
- **Services:**
    - `nginx`: listens on host `443`, reverse-proxies to `wordpress`
    - `wordpress`: PHP-FPM container, uses `/var/www/html` volume
    - `mariadb`: stores data under `/var/lib/mysql`
- **Networks:** single `inception` bridge network
- **Volumes:**
    - `wordpress-data` → `${DATA_PATH}/wordpress`
    - `mariadb-data`   → `${DATA_PATH}/mariadb`

---

## Data Persistence & Volumes

Data is persisted on the host in two bind-mounted volumes:

- **WordPress uploads:** `${DATA_PATH}/wordpress`
- **MariaDB data:**   `${DATA_PATH}/mariadb`

Change `DATA_PATH` in your `.env` to relocate data storage.

---


