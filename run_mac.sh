#!/usr/bin/env bash
# Based on https://learning-continuous-deployment.github.io/docker/images/dockerfile/2015/04/22/docker-gui-osx/
# and https://fredrikaverpil.github.io/2016/07/31/docker-for-mac-and-gui-applications/

# set -e
set -x

# open -a XQuartz --background 
# IP="192.168.246.1"

NET_INTERFACE="vmnet8" # en0
IP=$(ifconfig $NET_INTERFACE | grep inet | awk '$1=="inet" {print $2}')

xhost + $IP # run xhost and allow connections from the network

# sed -e 's/:.*$//'

# socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" &
# /opt/VirtualGL/bin/vglclient & # start VirtualGL client

  # Needef for VirtualGL
	# --volume="/usr/lib/x86_64-linux-gnu/libXv.so.1:/usr/lib/x86_64-linux-gnu/libXv.so.1" \
  
  # Stops QT from using the MIT-SHM X11 Shared Memory Extension
  # --env="QT_X11_NO_MITSHM=1" \

# https://docs.docker.com/engine/reference/run/#ipc-settings-ipc
# --ipc=private \
# or
# --ipc=host \

# --shm-size=2g - Size of /dev/shm, required for firefox, good for many other apps which utilize IPC

docker run -it --rm \
  --shm-size=2g \
	-e DISPLAY=$IP:0 \
	--volume="/tmp/.X11-unix:/tmp/.X11-unix:ro" \
  -v "/mnt/hgfs/VM-Shared/ros1/code:/code" \
  --device=/dev/dri:/dev/dri \
  ros1_ros-app bash
  # ros1_gazebo-non-nv bash

# SVGA_VGPU10=0 DISPLAY=:0 gazebo

  # -e XAUTHORITY=$XAUTH -v "$XAUTH:$XAUTH"

  # vglrun -fps 60 +sync glxgears
  # plumbee/nvidia-virtualgl vglrun -fps 60 +sync glxgears
  # ros1_gazebo bash
# apt-get install -y dbus
# dbus-uuidgen > /var/lib/dbus/machine-id

# firefox image that works travix/selenium-node-firefox

	# plumbee/nvidia-virtualgl vglrun glxgears



kill %1 # kill socat or vglclient from background


# No X install found.

# Warning: This script could not find mkinitrd or update-initramfs and cannot 
# remake the initrd file!


# glxinfo | grep "\(\(renderer\|vendor\|version\) string\)\|direct rendering"

# glxinfo | grep "OpenGL renderer string.*"