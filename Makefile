NAME = inception
COMPOSE =  docker compose -f srcs/docker-compose.yml
DATA_PATH = /home/${USER}/data

# Regla principal: levanta todo
all: setup build
	@printf "Lanzando configuración de ${NAME}...\n"
	${COMPOSE} up -d

# Crea los directorios necesarios, el archivo .env y los secretos si no existen
setup:
	@printf "Configurando entorno para ${NAME}...\n"
	@mkdir -p $(DATA_PATH)/mariadb
	@mkdir -p $(DATA_PATH)/wordpress
	@mkdir -p srcs/secrets
	@if [ ! -f srcs/.env ]; then \
		echo "Creando archivo .env predeterminado..."; \
		echo "SQL_DATABASE=inception" > srcs/.env; \
		echo "SQL_USER=user42" >> srcs/.env; \
		echo "WP_URL=localhost" >> srcs/.env; \
		echo "WP_TITLE=Inception" >> srcs/.env; \
		echo "WP_ADMIN_USER=admin" >> srcs/.env; \
		echo "WP_ADMIN_PASSWORD=adminpass" >> srcs/.env; \
		echo "WP_ADMIN_EMAIL=admin@example.com" >> srcs/.env; \
		echo "WP_USER=colleague" >> srcs/.env; \
		echo "WP_USER_PASSWORD=userpass" >> srcs/.env; \
		echo "WP_USER_EMAIL=user@example.com" >> srcs/.env; \
		echo "NGINX_PORT=443" >> srcs/.env; \
	fi
	@if [ ! -f srcs/secrets/db_password.txt ]; then \
		echo "Creando secreto db_password..."; \
		echo "password42" > srcs/secrets/db_password.txt; \
	fi
	@if [ ! -f srcs/secrets/db_root_password.txt ]; then \
		echo "Creando secreto db_root_password..."; \
		echo "root42" > srcs/secrets/db_root_password.txt; \
	fi

# Construye las imágenes
build:
	@printf "Construyendo imágenes de ${NAME}...\n"
	${COMPOSE} build 

# Detiene los contenedores
down:
	@printf "Deteniendo contenedores de ${NAME}...\n"
	${COMPOSE} down

# Limpieza profunda
clean: down 
	@printf "Limpiando configuración de ${NAME}...\n"
	@docker system prune -a

# Borrado total
fclean: clean 
	@printf "Borrando volúmenes y datos de ${NAME}...\n"
	@sudo rm -rf $(DATA_PATH)
	@rm -rf srcs/secrets
	@#rm -f srcs/.env

re: fclean all

.PHONY: all build down clean fclean re setup
