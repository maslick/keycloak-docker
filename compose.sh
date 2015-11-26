#!/bin/bash

# Run containeres 
docker-compose up -d db
sleep 10
docker-compose up -d keycloak
