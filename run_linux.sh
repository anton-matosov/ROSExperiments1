#!/usr/bin/env bash

PROJECT_NAME=ros1
SERVICE_NAME=ros-app

# don't rebuild every time
# docker-compose build $SERVICE_NAME

# --shm-size=2g - set shared memory device size to 2GB allowing apps relying on SM to function properly. e.g. Qt based apps, Firefox and Chrome
# -e DISPLAY - set display env var to current value of $DISPLAY env var (usually :0). This is need to properly forward xserver commands to xclient running on current desktop
# --device=/dev/dri:/dev/dri - allow acccessing GPU devices to docker container, this is must have to enable HW acceleration in container. In case of NVIDIA GPU you should use --driver=nvidia instead
docker run -it --rm \
  --name=$PROJECT_NAME"_"$SERVICE_NAME \
  --shm-size=2g \
	-e DISPLAY \
	-v "/tmp/.X11-unix:/tmp/.X11-unix:ro" \
  -v "/mnt/hgfs/VM-Shared/ros1/code:/code" \
  --device=/dev/dri:/dev/dri \
  $PROJECT_NAME"_"$SERVICE_NAME

# roslaunch u1 display.launch model:='$(find u1)/urdf/robot.urdf'
