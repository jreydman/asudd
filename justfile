set dotenv-load := true

docker_instance := "docker.lima"
compose_command := docker_instance + " compose --file ./docker/docker-compose.yaml --env-file ./.env"

default:
    @just --list

clear:
    @clear

compose-up *args: clear
    @{{ compose_command }} up -d {{ args }}

compose-down *args: clear
    @{{ compose_command }} down -v {{ args }}

compose-restart *args: clear
    @{{ compose_command }} down -v {{ args }}
    @{{ compose_command }} up -d {{ args }}

shell service: clear
    #!/usr/bin/env bash
    workdir=$(pwd)
    case "{{ service }}" in
        "webclient"|"database") workdir="/usr/src/app" ;;
    esac
    {{ docker_instance }} exec -it --env TERM=xterm-256color --workdir "$workdir" traffic-lights-{{ service }} /bin/bash

push-osm-data: clear
    @{{ compose_command }} exec -T database psql \
        --host localhost \
        --port ${DATABASE_PORT} \
        --username ${DATABASE_USER} \
        --password ${DATABASE_PASSWORD} \
        --dbname ${DATABASE_NAME} \
        -c "CREATE SCHEMA IF NOT EXISTS osm_ukraine_kyiv;"
    @osm2pgrouting \
        --file data/osm/ukraine-kyiv-latest.osm \
        --conf data/osm/mapconfig.xml \
        --host localhost \
        --port ${DATABASE_PORT} \
        --username ${DATABASE_USER} \
        --password ${DATABASE_PASSWORD} \
        --dbname ${DATABASE_NAME} \
        --schema osm_ukraine_kyiv \
        --clean
