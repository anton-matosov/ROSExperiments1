#!/usr/bin/env bash
# Based on https://learning-continuous-deployment.github.io/docker/images/dockerfile/2015/04/22/docker-gui-osx/
# and https://fredrikaverpil.github.io/2016/07/31/docker-for-mac-and-gui-applications/

set -e
set -x

open -a XQuartz

# run xhost and allow connections from your local machine
IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
xhost + $IP

socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" &

# docker run -it \
# 	-e DISPLAY=$IP:0 \
# 	--ipc=host \
# 	-v /tmp/.X11-unix:/tmp/.X11-unix \
# 	-v $(pwd)/code:/code \
# 	--rm=true \
# 	--name "ros-app-for-mac" \
# 	--privileged \
# 	ros1_ros-app

	# --env="DISPLAY" \
  # -e VGL_DISPLAY=:1 \
docker run -it --rm \
	-e DISPLAY=$IP:0 \
	--ipc=host \
  -e VGL_DISPLAY=:1 \
  --runtime=nvidia \
	--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
	--volume="/usr/lib/x86_64-linux-gnu/libXv.so.1:/usr/lib/x86_64-linux-gnu/libXv.so.1" \
  ros1_gazebo bash

	# plumbee/nvidia-virtualgl vglrun glxgears

# docker run -it --privileged \
#   -e SVGA_VGPU10=0 \
#   --env=LOCAL_USER_ID="$(id -u)" \
#   -v ~/src/Firmware:/src/firmware/:rw \
#   -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
#   -e DISPLAY=$IP:0 \
#   -p 14556:14556/udp \
#   --name=px4 \
#   --rm \
#   px4io/px4-dev-ros

kill %1 # kill socat from background
