COMPOSE = docker compose
SRCS = srcs/docker-compose.yml
BONUS = srcs/docker-compose.bonus.yml

DB_USER ?= alebarbo
DB_PASS ?= $(shell cat secrets/db_password.txt)
DB_NAME ?= wordpress

.PHONY: all setup up bonus down logs ps clean fclean re

all: setup up

setup:
	mkdir -p ~/data/db
	mkdir -p ~/data/wordpress

up:
	$(COMPOSE) -f $(SRCS) up --build -d

bonus:
	$(COMPOSE) -f $(SRCS) -f $(BONUS) up --build -d

down:
	$(COMPOSE) -f $(SRCS) -f $(BONUS) down

logs:
	$(COMPOSE) -f $(SRCS) -f $(BONUS) logs

ps:
	$(COMPOSE) -f $(SRCS) -f $(BONUS) ps

db:
	$(COMPOSE) -f $(SRCS) exec mariadb sh -c 'mysql -u $(DB_USER) -p"$(DB_PASS)" $(DB_NAME)'

clean:
	$(COMPOSE) -f $(SRCS) -f $(BONUS) down -v --rmi all --remove-orphans

fclean: clean
	sudo rm -rf ~/data

re: fclean all
