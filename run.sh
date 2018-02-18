#!/usr/bin/env bash
set -e
set -x

until docker ps > /dev/null
do
    echo "Waiting for docker server"
    sleep 1
done


# Make sure processes in the container can connect to the x server
# Necessary so RQT and Gazebo can create a context for OpenGL rendering (even headless)
XAUTH=/tmp/.docker.xauth
if [ ! -f $XAUTH ]
then
    xauth_list=$(xauth nlist :0 | sed -e 's/^..../ffff/')
    if [ ! -z "$xauth_list" ]
    then
        echo $xauth_list | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH
fi

#   -e QT_X11_NO_MITSHM=1 \
#   -v "/etc/localtime:/etc/localtime:ro" \
#   -v "/dev/input:/dev/input" \
docker run -it \
  -e DISPLAY=:0 \
  -e SVGA_VGPU10=0 \
  -e XAUTHORITY=$XAUTH \
  -v "$XAUTH:$XAUTH" \
  -v "/tmp/.X11-unix:/tmp/.X11-unix" \
  -v "/mnt/hgfs/VM-Shared/ros1/code:/code" \
  --privileged \
  --rm=true \
  ros1_ros-app

