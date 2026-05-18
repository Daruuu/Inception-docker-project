# Variables
NAME          = inception
LOGIN         = $(USER)
DATA_PATH     = /home/$(USER)/data
DOMAIN        = dasalaza.42.fr

# paths and commands
SRCS_DIR      = ./srcs
COMPOSE       = docker compose -f $(SRCS_DIR)/docker-compose.yml

# Colors
GREEN         = \033[0;32m
RED           = \033[0;31m
YELLOW        = \033[0;33m
BLUE          = \033[0;34m
RESET         = \033[0m

all: setup build up

# 1. Setup environment
setup:
	@printf "$(BLUE)Setup environment: $(NAME)...$(RESET)\n"
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress
	@mkdir -p $(DATA_PATH)/static
	@mkdir -p $(DATA_PATH)/netdata/cache
	@mkdir -p $(DATA_PATH)/netdata/config
	@mkdir -p $(DATA_PATH)/netdata/lib
	@mkdir -p $(DATA_PATH)/secrets
	@mkdir -p $(SRCS_DIR)/secrets

	@# Generate file .env if not exist
	@if [ ! -f $(SRCS_DIR)/.env ]; then \
		echo "$(YELLOW)Creating file .env...$(RESET)"; \
		echo "SQL_DATABASE=$(NAME)" > $(SRCS_DIR)/.env; \
		echo "SQL_USER=$(LOGIN)" >> $(SRCS_DIR)/.env; \
		echo "WP_URL=$(DOMAIN)" >> $(SRCS_DIR)/.env; \
		echo "WP_TITLE=$(NAME)" >> $(SRCS_DIR)/.env; \
		echo "WP_ADMIN_USER=$(LOGIN)_super" >> $(SRCS_DIR)/.env; \
		echo "WP_ADMIN_EMAIL=$(LOGIN)@student.42.fr" >> $(SRCS_DIR)/.env; \
		echo "WP_USER=$(USER)42" >> $(SRCS_DIR)/.env; \
		echo "WP_USER_EMAIL=$(USER)42@example.com" >> $(SRCS_DIR)/.env; \
		echo "NGINX_PORT=443" >> $(SRCS_DIR)/.env; \
		echo "USER=${USER}" >> $(SRCS_DIR)/.env; \
	fi
	@# Generate passwords with OpenSSL in secrets
	@if [ ! -f $(SRCS_DIR)/secrets/db_password.txt ]; then \
		echo "Creando db_password..."; \
		openssl rand -base64 8 > $(SRCS_DIR)/secrets/db_password.txt; \
	fi
	@if [ ! -f $(SRCS_DIR)/secrets/db_root_password.txt ]; then \
		echo "Creando db_root_n_password..."; \
		openssl rand -base64 8 > $(SRCS_DIR)/secrets/db_root_password.txt; \
	fi
	@if [ ! -f $(SRCS_DIR)/secrets/wp_admin_password.txt ]; then \
		echo "Creando wp_admin_password..."; \
		openssl rand -base64 8 > $(SRCS_DIR)/secrets/wp_admin_password.txt; \
	fi
	@if [ ! -f $(SRCS_DIR)/secrets/wp_user_password.txt ]; then \
		echo "Creando wp_user_password..."; \
		openssl rand -base64 8 > srcs/secrets/wp_user_password.txt; \
	fi
	@if [ ! -f $(SRCS_DIR)/secrets/ftp_password.txt ]; then \
		echo "Creando ftp_password..."; \
		openssl rand -base64 8 > srcs/secrets/ftp_password.txt; \
	fi

# 2. Construcción
build:
	@printf "$(YELLOW)Construyendo imágenes de $(NAME)...$(RESET)\n"
	@$(COMPOSE) build

# 3. Lanzamiento
up:
	@printf "$(GREEN)Lanzando contenedores de $(NAME)...$(RESET)\n"
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
	@sudo rm -rf $(DATA_PATH)
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
	@docker volume ls | grep $(NAME) || echo "No hay volúmenes activos."

# Rules to access fast to containers
nginx:
	@$(COMPOSE) exec nginx sh
nginx-up: setup
	@docker compose -f srcs/docker-compose.yml up -d nginx

mariadb:
	@$(COMPOSE) exec mariadb sh
mariadb-up: setup
	@docker compose -f srcs/docker-compose.yml up -d mariadb

wordpress:
	@$(COMPOSE) exec wordpress sh
wordpress-up:
	@docker compose -f srcs/docker-compose.yml up -d wordpress

.PHONY: all setup build up down clean fclean re logs ps status nginx mariadb wordpress