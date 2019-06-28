#!/bin/bash

# Run containers
docker-compose up -d keycloak -f docker-compose-my.yml
docker-compose logs -f