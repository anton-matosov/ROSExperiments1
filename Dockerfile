FROM ros1_tf-ros:latest

ENV ROS_DISTRO=melodic


# Gazebo downgrade to OpenGL 2 in VMs
ENV SVGA_VGPU10 0

ADD ./code /code
WORKDIR /code

RUN apt-get update \
	&& apt-get install -y \
	&& python3 \
	&& python3-pip \
	&& fish \
	&& apt-utils \
	&& python-rosinstall \
	&& python-rosinstall-generator \
	&& python-wstool \
	&& build-essential \
  && pip3 install --upgrade pip \
  && pip3 install -r requirements.txt


# Install Gazebo
# RUN apt-get update && \
# 	apt-get install -y wget \
# 	&& wget --quiet http://packages.osrfoundation.org/gazebo.key -O - | apt-key add - \
# 	&& sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable xenial main" > /etc/apt/sources.list.d/gazebo-stable.list' \
# 	&& apt-get update \
# 	&& DEBIAN_FRONTEND=noninteractive apt-get -y --quiet --no-install-recommends install \
# 	gazebo9 \
# 	libgazebo9 \
# 	libsdformat6 \
# 	gazebo9-common \
# 	mesa-utils \
# 	xserver-xorg-video-all \
# 	libgl1-mesa-glx \
# 	evince

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get -y --quiet --no-install-recommends install \
	ros-$ROS_DISTRO-turtle-tf2 \
	ros-$ROS_DISTRO-tf2-tools \
	ros-$ROS_DISTRO-tf


ADD ./docker/ros_entrypoint.sh /ros_entrypoint.sh
ENTRYPOINT ["bash", "/ros_entrypoint.sh"]

CMD ["fish"]
