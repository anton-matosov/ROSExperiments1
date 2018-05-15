FROM osrf/ros:lunar-desktop-full-xenial

# Gazebo downgrade to OpenGL 2 in VMs
ENV SVGA_VGPU10 0

ADD ./code /code
WORKDIR /code

RUN apt-get update 

RUN apt-get install -y python3 python3-pip fish apt-utils
# RUN apt-get upgrade -y python
RUN pip3 install --upgrade pip
RUN pip3 install -r requirements.txt

# RUN cd /usr/bin && ln -sf python3 python

RUN apt-get install -y python-rosinstall python-rosinstall-generator python-wstool build-essential
# RUN apt-get install -y python3-rosinstall python3-rosinstall-generator python3-wstool build-essential python3-catkin-pkg python3-rosdistro python3-rospkg


# Install Gazebo
RUN apt-get install -y wget
RUN wget --quiet http://packages.osrfoundation.org/gazebo.key -O - | apt-key add - \
	&& sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable xenial main" > /etc/apt/sources.list.d/gazebo-stable.list' \
	&& apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get -y --quiet --no-install-recommends install \
	gazebo9 \
	libgazebo9 \
	libsdformat6 \
	gazebo9-common \
	mesa-utils \
	xserver-xorg-video-all \
	libgl1-mesa-glx

# && apt-get -y autoremove \
# && apt-get clean autoclean \
# && rm -rf /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*


ADD ./ros_app_entrypoint.sh /ros_app_entrypoint.sh
ENTRYPOINT ["bash", "/ros_app_entrypoint.sh"]

CMD ["fish"]
