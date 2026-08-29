.PHONY: all setup up bonus down logs ps clean fclean re

all: setup up

setup:
	mkdir -p /home/alebarbo/data/db
	mkdir -p /home/alebarbo/data/wordpress

up:
	docker compose -p inception -f srcs/docker-compose.yml up --build -d

bonus:
	docker compose -p inception -f srcs/docker-compose.yml -f srcs/docker-compose.bonus.yml up --build -d

down:
	docker compose -p inception -f srcs/docker-compose.yml down

logs:
	docker compose -p inception -f srcs/docker-compose.yml logs -f

ps:
	docker compose -p inception -f srcs/docker-compose.yml ps

clean: down
	docker image rm -f nginx wordpress mariadb 2>/dev/null || true

fclean: clean
	docker compose -p inception -f srcs/docker-compose.yml down -v
	rm -rf /home/alebarbo/data/db/*
	rm -rf /home/alebarbo/data/wordpress/*

re: fclean all
