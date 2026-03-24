#!/bin/bash

# Login to run before shutting down

echo "$(date) | Running script user.stop.sh ..."

echo "Environment: $ENVIRONMENT"
echo "Greenhouse config path: $GREENHOUSE_CONFIG_PATH"
echo "Greenhouse Docker path: $GREENHOUSE_DOCKER_PATH"

# cd $GREENHOUSE_DOCKER_PATH
# docker compose --file "$GREENHOUSE_DOCKER_PATH/docker-compose.yml" --env-file "$GREENHOUSE_CONFIG_PATH" --project-name "$ENVIRONMENT" down

echo "$(date) | Run completed"