#!/bin/bash

# Run containers
docker-compose up -d keycloak
docker-compose logs -f