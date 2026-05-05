# Variables de identidad
NAME          = inception
LOGIN         = $(USER)
DATA_PATH     = /home/$(LOGIN)/data
DOMAIN        = dasalaza.42.fr

# Rutas y Comandos
SRCS_DIR      = ./srcs
COMPOSE       = docker compose -f $(SRCS_DIR)/docker-compose.yml

# Colores para una terminal bonita
GREEN         = \033[0;32m
RED           = \033[0;31m
YELLOW        = \033[0;33m
BLUE          = \033[0;34m
RESET         = \033[0m

# --- REGLAS PRINCIPALES ---

all: setup build up

# 1. Preparación del entorno
setup:
	@printf "$(BLUE)Configurando entorno para $(NAME)...$(RESET)\n"
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress
	@mkdir -p $(SRCS_DIR)/secrets
	@# Generación del .env si no existe
	@if [ ! -f $(SRCS_DIR)/.env ]; then \
		echo "$(YELLOW)Creando archivo .env...$(RESET)"; \
		echo "SQL_DATABASE=inception" > $(SRCS_DIR)/.env; \
		echo "SQL_USER=$(LOGIN)" >> $(SRCS_DIR)/.env; \
		echo "WP_URL=$(DOMAIN)" >> $(SRCS_DIR)/.env; \
		echo "WP_TITLE=Inception" >> $(SRCS_DIR)/.env; \
		echo "WP_ADMIN_USER=$(LOGIN)_admin" >> $(SRCS_DIR)/.env; \
		echo "WP_ADMIN_EMAIL=$(LOGIN)@student.42.fr" >> $(SRCS_DIR)/.env; \
		echo "WP_USER=colleague" >> $(SRCS_DIR)/.env; \
		echo "WP_USER_EMAIL=user@example.com" >> $(SRCS_DIR)/.env; \
		echo "NGINX_PORT=443" >> $(SRCS_DIR)/.env; \
	fi
	@# Generación de secretos con OpenSSL (Seguridad Pro)
	@if [ ! -f $(SRCS_DIR)/secrets/db_password.txt ]; then \
		openssl rand -base64 16 > $(SRCS_DIR)/secrets/db_password.txt; \
	fi
	@if [ ! -f $(SRCS_DIR)/secrets/db_root_password.txt ]; then \
		openssl rand -base64 16 > $(SRCS_DIR)/secrets/db_root_password.txt; \
	fi
	@if [ ! -f $(SRCS_DIR)/secrets/wp_admin_password.txt ]; then \
		openssl rand -base64 16 > $(SRCS_DIR)/secrets/wp_admin_password.txt; \
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

fclean:
	@printf "$(RED)BORRADO TOTAL (Datos, Secretos y Contenedores)...$(RESET)\n"
	@$(COMPOSE) down -v --rmi all
	@sudo rm -rf $(DATA_PATH)
	@rm -f $(SRCS_DIR)/.env
	@rm -rf $(SRCS_DIR)/secrets
	@docker system prune -af

re: fclean all

# --- UTILIDADES Y DEBUG ---

logs:
	@$(COMPOSE) logs -f

ps:
	@$(COMPOSE) ps

status:
	@printf "$(BLUE)Estado de los contenedores:$(RESET)\n"
	@$(COMPOSE) ps
	@printf "\n$(BLUE)Volúmenes:$(RESET)\n"
	@docker volume ls | grep $(NAME) || echo "No hay volúmenes activos."

# Acceso rápido a contenedores
nginx:
	@$(COMPOSE) exec nginx sh

mariadb:
	@$(COMPOSE) exec mariadb sh

wordpress:
	@$(COMPOSE) exec wordpress sh

.PHONY: all setup build up down clean fclean re logs ps status nginx mariadb wordpress