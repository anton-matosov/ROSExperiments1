#!/usr/bin/env bash

PROJECT_NAME=ros1
SERVICE_NAME=ros-app

docker exec -it $PROJECT_NAME"_"$SERVICE_NAME $@
