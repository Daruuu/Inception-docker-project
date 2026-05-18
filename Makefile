# =============================================================================
# Variables del host (solo Makefile — Fase 1)
# Los nombres del .env no cambian hasta la Fase 2.
#
# Makefile              →  srcs/.env
# PROJECT_NAME          →  SQL_DATABASE, WP_TITLE
# STUDENT_LOGIN         →  SQL_USER, WP_ADMIN_*, USER
# SITE_DOMAIN           →  WP_URL
# WORDPRESS_AUTHOR_*    →  WP_USER, WP_USER_EMAIL
# =============================================================================

PROJECT_NAME           = inception
STUDENT_LOGIN          = dasalaza
SITE_DOMAIN            = $(STUDENT_LOGIN).42.fr
HOST_DATA_PATH         = /home/$(USER)/data

# Segundo usuario WordPress (subject: no puede contener "admin")
WORDPRESS_AUTHOR_LOGIN = $(STUDENT_LOGIN)42
WORDPRESS_AUTHOR_EMAIL = $(WORDPRESS_AUTHOR_LOGIN)@example.com

# Rutas y comandos
SRCS_DIR               = ./srcs
COMPOSE                = docker compose -f $(SRCS_DIR)/docker-compose.yml

# Colores
GREEN                  = \033[0;32m
RED                    = \033[0;31m
YELLOW                 = \033[0;33m
BLUE                   = \033[0;34m
RESET                  = \033[0m

all: setup build up

# 1. Setup environment
setup:
	@printf "$(BLUE)Setup environment: $(PROJECT_NAME)...$(RESET)\n"
	@mkdir -p $(HOST_DATA_PATH)/mariadb
	@mkdir -p $(HOST_DATA_PATH)/wordpress
	@mkdir -p $(HOST_DATA_PATH)/static
	@mkdir -p $(HOST_DATA_PATH)/netdata/cache
	@mkdir -p $(HOST_DATA_PATH)/netdata/config
	@mkdir -p $(HOST_DATA_PATH)/netdata/lib
	@mkdir -p $(HOST_DATA_PATH)/secrets
	@mkdir -p $(SRCS_DIR)/secrets

	@# Genera srcs/.env (claves legacy; ver mapeo en cabecera del Makefile)
	@if [ ! -f $(SRCS_DIR)/.env ]; then \
		echo "$(YELLOW)Creating file .env...$(RESET)"; \
		echo "SQL_DATABASE=$(PROJECT_NAME)" > $(SRCS_DIR)/.env; \
		echo "SQL_USER=$(STUDENT_LOGIN)" >> $(SRCS_DIR)/.env; \
		echo "WP_URL=$(SITE_DOMAIN)" >> $(SRCS_DIR)/.env; \
		echo "WP_TITLE=$(PROJECT_NAME)" >> $(SRCS_DIR)/.env; \
		echo "WP_ADMIN_USER=$(STUDENT_LOGIN)_super" >> $(SRCS_DIR)/.env; \
		echo "WP_ADMIN_EMAIL=$(STUDENT_LOGIN)@student.42.fr" >> $(SRCS_DIR)/.env; \
		echo "WP_USER=$(WORDPRESS_AUTHOR_LOGIN)" >> $(SRCS_DIR)/.env; \
		echo "WP_USER_EMAIL=$(WORDPRESS_AUTHOR_EMAIL)" >> $(SRCS_DIR)/.env; \
		echo "NGINX_PORT=443" >> $(SRCS_DIR)/.env; \
		echo "USER=$(STUDENT_LOGIN)" >> $(SRCS_DIR)/.env; \
	fi
	@# Contraseñas en secrets (Docker secrets)
	@if [ ! -f $(SRCS_DIR)/secrets/db_password.txt ]; then \
		echo "Creando db_password..."; \
		openssl rand -base64 8 > $(SRCS_DIR)/secrets/db_password.txt; \
	fi
	@if [ ! -f $(SRCS_DIR)/secrets/db_root_password.txt ]; then \
		echo "Creando db_root_password..."; \
		openssl rand -base64 8 > $(SRCS_DIR)/secrets/db_root_password.txt; \
	fi
	@if [ ! -f $(SRCS_DIR)/secrets/wp_admin_password.txt ]; then \
		echo "Creando wp_admin_password..."; \
		openssl rand -base64 8 > $(SRCS_DIR)/secrets/wp_admin_password.txt; \
	fi
	@if [ ! -f $(SRCS_DIR)/secrets/wp_user_password.txt ]; then \
		echo "Creando wp_user_password..."; \
		openssl rand -base64 8 > $(SRCS_DIR)/secrets/wp_user_password.txt; \
	fi
	@if [ ! -f $(SRCS_DIR)/secrets/ftp_password.txt ]; then \
		echo "Creando ftp_password..."; \
		openssl rand -base64 8 > $(SRCS_DIR)/secrets/ftp_password.txt; \
	fi

# 2. Construcción
build:
	@printf "$(YELLOW)Construyendo imágenes de $(PROJECT_NAME)...$(RESET)\n"
	@$(COMPOSE) build

# 3. Lanzamiento
up:
	@printf "$(GREEN)Lanzando contenedores de $(PROJECT_NAME)...$(RESET)\n"
	@$(COMPOSE) up -d

# --- REGLAS DE LIMPIEZA ---

down:
	@printf "$(RED)Deteniendo contenedores...$(RESET)\n"
	@$(COMPOSE) down

clean: down
	@printf "$(RED)Eliminando contenedores y redes...$(RESET)\n"
	@$(COMPOSE) down --rmi all

fclean: clean
	@printf "$(RED)BORRADO TOTAL (Datos, Secretos y Contenedores)...$(RESET)\n"
	@$(COMPOSE) down -v --rmi all
	@sudo rm -rf $(HOST_DATA_PATH)
	@rm -f $(SRCS_DIR)/.env
	@rm -rf $(SRCS_DIR)/secrets
	@docker system prune -af

re: fclean all

# --- UTILITIES and DEBUG ---

logs:
	@$(COMPOSE) logs -f

ps:
	@$(COMPOSE) ps

status:
	@printf "$(BLUE)Estado de los contenedores:$(RESET)\n"
	@$(COMPOSE) ps
	@printf "\n$(BLUE)Volúmenes:$(RESET)\n"
	@docker volume ls | grep $(PROJECT_NAME) || echo "No hay volúmenes activos."

# Rules to access fast to containers
nginx:
	@$(COMPOSE) exec nginx sh
nginx-up: setup
	@$(COMPOSE) up -d nginx

mariadb:
	@$(COMPOSE) exec mariadb sh
mariadb-up: setup
	@$(COMPOSE) up -d mariadb

wordpress:
	@$(COMPOSE) exec wordpress sh
wordpress-up: setup
	@$(COMPOSE) up -d wordpress

.PHONY: all setup build up down clean fclean re logs ps status nginx mariadb wordpress
