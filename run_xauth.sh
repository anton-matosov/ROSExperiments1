#!/usr/bin/env bash


XAUTH=~/.docker.xauth
# if [ ! -f $XAUTH ]
# then
#     xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
#     if [ ! -z "$xauth_list" ]
#     then
#         echo $xauth_list | xauth -f $XAUTH nmerge -
#     else
#         touch $XAUTH
#     fi
#     chmod a+r $XAUTH
# fi

  # -e XAUTHORITY=/tmp/.docker.xauth \
  # -v "$XAUTH:/tmp/.docker.xauth" \

docker run -it --rm \
	--ipc=host \
	-e DISPLAY=:0 \
	-v "/tmp/.X11-unix:/tmp/.X11-unix:ro" \
  -v "/mnt/hgfs/VM-Shared/ros1/code:/code" \
  --device=/dev/dri:/dev/dri \
  ros1_gazebo-non-nv bash

