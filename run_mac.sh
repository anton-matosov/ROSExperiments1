#!/usr/bin/env bash
# Based on https://learning-continuous-deployment.github.io/docker/images/dockerfile/2015/04/22/docker-gui-osx/
# and https://fredrikaverpil.github.io/2016/07/31/docker-for-mac-and-gui-applications/

# set -e
set -x

open -a XQuartz 

# run xhost and allow connections from your local machine
IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
xhost + $IP

# /opt/VirtualGL/bin/vglclient
# socat TCP-LISTEN:6000,reuseaddr,fork UNIX-CLIENT:\"$DISPLAY\" &

# docker run -it \
# 	-e DISPLAY=$IP:0 \
# 	--ipc=host \
# 	-v /tmp/.X11-unix:/tmp/.X11-unix:rw \
# 	-v ${PWD}/code:/code \
# 	--rm=true \
# 	--name "ros-app-for-mac" \
# 	--privileged \
# 	ros1_gazebo-non-nv bash
  #  vglrun -fps 60 +sync glxgears

	# run from mac on Linux VM or Linux PC
  
	# --volume="/var/lib/dbus/machine-id:/var/lib/dbus/machine-id:ro" \

	# --volume="/dev/shm:/dev/shm:rw" \

# --shm-size 2g
# -v /dev/shm:/dev/shm:rw

  # -v "/home/anton/Temp/vmware-tools-distrib/:/vmware-tools-distrib/" \
  # -v "/lib/modules/4.13.0-32-generic:/lib/modules/4.13.0-32-generic" \

  # Needef for VirtualGL
	# --volume="/usr/lib/x86_64-linux-gnu/libXv.so.1:/usr/lib/x86_64-linux-gnu/libXv.so.1" \
  
  # Stops QT from using the MIT-SHM X11 Shared Memory Extension
  # --env="QT_X11_NO_MITSHM=1" \

docker run -it --rm \
	--ipc=host \
	-e DISPLAY=$IP:0 \
	--volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
  -v "/mnt/hgfs/VM-Shared/ros1/code:/code" \
  --device=/dev/dri:/dev/dri \
  ros1_gazebo-non-nv bash

# SVGA_VGPU10=0 DISPLAY=:0 gazebo

  # -e XAUTHORITY=$XAUTH -v "$XAUTH:$XAUTH"

  # vglrun -fps 60 +sync glxgears
  # plumbee/nvidia-virtualgl vglrun -fps 60 +sync glxgears
  # ros1_gazebo bash
# apt-get install -y dbus
# dbus-uuidgen > /var/lib/dbus/machine-id

# firefox image that works travix/selenium-node-firefox

	# plumbee/nvidia-virtualgl vglrun glxgears



kill %1 # kill socat from background


# No X install found.

# Warning: This script could not find mkinitrd or update-initramfs and cannot 
# remake the initrd file!


# glxinfo | grep "\(\(renderer\|vendor\|version\) string\)\|direct rendering"

# glxinfo | grep "OpenGL renderer string.*"