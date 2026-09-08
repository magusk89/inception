COMPOSE = docker compose
SRCS = srcs/docker-compose.yml
BONUS = srcs/docker-compose.bonus.yml

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

clean:
	$(COMPOSE) -f $(SRCS) -f $(BONUS) down -v --rmi all --remove-orphans

fclean: clean
	rm -rf ~/data/db
	rm -rf ~/data/wordpress

re: fclean all
