include .env
export

docker_instance = docker.lima
docker_compose_prompt = $(docker_instance) compose --file ./docker/docker-compose.yaml --env-file ./.env

clear:
	@clear

# ------------------------------------------------------------------------------

compose-up: clear
	@$(docker_compose_prompt) up -d $(filter-out $@,$(MAKECMDGOALS))

compose-down: clear
	@$(docker_compose_prompt) down -v $(filter-out $@,$(MAKECMDGOALS))

compose-restart: clear
	@$(docker_compose_prompt) down -v $(filter-out $@,$(MAKECMDGOALS))
	@$(docker_compose_prompt) up -d $(filter-out $@,$(MAKECMDGOALS))

shell-%: clear
	@workdir=$(shell pwd); \
	if [ "$*" = "webclient" ]; then workdir="/usr/src/app"; fi; \
	if [ "$*" = "database" ]; then workdir="/usr/src/app"; fi; \
	$(docker_instance) exec -it --workdir "$$workdir" traffic-lights-$(*) /bin/bash

# ------------------------------------------------------------------------------

%:
	@:
