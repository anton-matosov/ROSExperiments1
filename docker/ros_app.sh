#!/usr/bin/env bash

source /opt/ros/$ROS_DISTRO/setup.bash
source ${CATKIN_PY3_WS}/install/setup.bash --extend

"$@"
