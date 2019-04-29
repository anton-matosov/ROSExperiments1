FROM ros1_ros-tf:latest

ARG ROS_DISTRO=melodic
ENV ROS_DISTRO=${ROS_DISTRO}

ARG USE_PYTHON_3_NOT_2
ARG _PY_SUFFIX=${USE_PYTHON_3_NOT_2:+3}
ARG PYTHON=python${_PY_SUFFIX}
ARG PIP=pip${_PY_SUFFIX}

# Gazebo downgrade to OpenGL 2 in VMs
ENV SVGA_VGPU10 0


RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive \
		apt-get install -y \
    ${PYTHON} \
    ${PYTHON}-pip \
    ${PYTHON}-yaml \
		fish \
		mesa-utils \
		xserver-xorg-video-all \
		libgl1-mesa-glx \
		evince

RUN ${PIP} --no-cache-dir install --upgrade pip setuptools

ADD ./code /code
WORKDIR /code

RUN ${PIP} install -r requirements.txt

# ROS 1 extras and support for python3
RUN ${PIP} install rospkg catkin_pkg \
	&& apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get -y --quiet --no-install-recommends install \
		apt-utils \
		python-rosinstall \
		python-rosinstall-generator \
		python-catkin-tools \
		python3-dev \
		python3-numpy \
		python-wstool \
		build-essential \
		ros-$ROS_DISTRO-turtle-tf2 \
		ros-$ROS_DISTRO-tf2-tools \
		ros-$ROS_DISTRO-tf


RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt install -y \
		python3-dev \
		zlib1g-dev \
		libjpeg-dev \
		cmake \
		swig \
		python-pyglet \
		python3-opengl \
		libboost-all-dev \
		libsdl2-dev \
		libosmesa6-dev \
		patchelf \
		ffmpeg \
		xvfb \
		&& ${PIP} install -y 'gym[all]' 

# Create python3 fiendly catkin workspace
ENV CATKIN_PY3_WS=~/catkin_build_ws
RUN mkdir ${CATKIN_PY3_WS} \
	&& cd ${CATKIN_PY3_WS} \
	&& catkin config -DPYTHON_EXECUTABLE=/usr/bin/python3 \
			-DPYTHON_INCLUDE_DIR=/usr/include/python3.6m \
			-DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.6m.so \
	&& catkin config --install
WORKDIR ${CATKIN_PY3_WS}

# rosunit for python3 https://github.com/ros/ros/issues/158
# might be not needed in latest version
# RUN cd ${CATKIN_PY3_WS}/src \
# 	&& git clone https://github.com/ros/ros \
# 	&& cd ${CATKIN_PY3_WS} \
# 	&& catkin_make_isolated --install --pkg rosunit -DCMAKE_BUILD_TYPE=Release --install-space /opt/ros/melodic \
# 	&& rm -rf "${CATKIN_PY3_WS}/src/ros"

ADD ./docker/ros_entrypoint.sh /ros_entrypoint.sh
ENTRYPOINT ["/ros_entrypoint.sh"]

CMD ["bash", "-c", "source /etc/bash.bashrc && jupyter notebook --notebook-dir=/tf --ip 0.0.0.0 --no-browser --allow-root"]
