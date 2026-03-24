#!/bin/bash

# Login to run after start up

echo "$(date) | Running script user.start.sh ..."

echo "Environment: $ENVIRONMENT"
echo "Greenhouse config path: $GREENHOUSE_CONFIG_PATH"
echo "Greenhouse Docker path: $GREENHOUSE_DOCKER_PATH"
echo "Sleeping 2 minutes to ensure docker has started."

sleep 120

cd $GREENHOUSE_DOCKER_PATH
docker compose --file "$GREENHOUSE_DOCKER_PATH/docker-compose.yml" --env-file "$GREENHOUSE_CONFIG_PATH" --project-name "$ENVIRONMENT" down
docker compose --file "$GREENHOUSE_DOCKER_PATH/docker-compose.yml" --env-file "$GREENHOUSE_CONFIG_PATH" --project-name "$ENVIRONMENT" up -d

echo "$(date) | Run completed"

docker container ls