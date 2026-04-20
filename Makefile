# Colors
GREEN		= \033[0;32m
RED			= \033[0;31m
YELLOW		= \033[0;33m
BLUE		= \033[0;34m
RESET		= \033[0m

NAME		= inception

SRCS_DIR	= ./srcs
COMPOSE		= docker compose -f $(SRCS_DIR)/../docker-compose.yml

# Targets
all: build up

#	@echo "$(YELLOW)Building Docker images...$(RESET)"
build:
	$(COMPOSE) build --no-cache

#	@echo "$(GREEN)Starting $(NAME)...$(RESET)"
up:
	$(COMPOSE) up -d --build

#	@echo "$(RED)Stopping $(NAME)...$(RESET)"
down:
	$(COMPOSE) down

re: down build up

#	@echo "$(RED)Stopping and removing containers...$(RESET)"
clean:
	$(COMPOSE) down

#	@echo "$(RED)Removing all volumes and images...$(RESET)"
fclean: clean
	$(COMPOSE) down --volumes --rmi all
	docker system prune -f

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

status:
	@echo "$(BLUE)Containers status:$(RESET)"
	$(COMPOSE) ps
	@echo "\n$(BLUE)Volumes:$(RESET)"
	docker volume ls | grep inception || echo "No volumes found"

nginx:
	$(COMPOSE) exec nginx bash

wordpress:
	$(COMPOSE) exec wordpress bash

mariadb:
	$(COMPOSE) exec mariadb bash

# Bonus targets (útil cuando añadas redis, ftp, etc.)
bonus: re

# Ayuda
help:
	@echo "$(BLUE)=== Inception Makefile Commands ===$(RESET)"
	@echo "make all          → Build and start the project"
	@echo "make build        → Build all Docker images"
	@echo "make up           → Start containers in detached mode"
	@echo "make down         → Stop containers"
	@echo "make re           → Restart the entire project"
	@echo "make clean        → Stop containers"
	@echo "make fclean       → Full cleanup (containers + volumes + images)"
	@echo "make logs         → Show logs in real time"
	@echo "make ps           → Show running containers"
	@echo "make status       → Show containers and volumes"
	@echo "make nginx        → Enter nginx container"
	@echo "make wordpress    → Enter wordpress container"
	@echo "make mariadb      → Enter mariadb container"
	@echo "make help         → Show this help"

.PHONY: all build up down re clean fclean logs ps status nginx wordpress mariadb bonus help