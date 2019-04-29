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
		fish \
		mesa-utils \
		xserver-xorg-video-all \
		libgl1-mesa-glx \
		evince

RUN ${PIP} --no-cache-dir install --upgrade pip setuptools

ADD ./code /code
WORKDIR /code

RUN ${PIP} install -r /code/requirements.txt

# ROS 1 extras and support for python3
RUN ${PIP} install rospkg catkin_pkg \
	&& apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get -y --quiet --no-install-recommends install \
		apt-utils \
		${PYTHON}-rosinstall \
		${PYTHON}-rosinstall-generator \
		${PYTHON}-catkin-tools \
		${PYTHON}-dev \
		${PYTHON}-numpy \
		${PYTHON}-wstool \
		${PYTHON}-cv-bridge \
		build-essential \
		ros-$ROS_DISTRO-turtle-tf2 \
		ros-$ROS_DISTRO-tf2-tools \
		ros-$ROS_DISTRO-tf


RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt install -y \
		cmake \
		ffmpeg \
		libboost-all-dev \
		libjpeg-dev \
		libosmesa6-dev \
		libsdl2-dev \
		patchelf \
		${PYTHON}-pyglet \
		${PYTHON}-dev \
		${PYTHON}-opengl \
		swig \
		xvfb \
		zlib1g-dev

# Rendering on server needs` display `xvfb-run -s "-screen 0 1400x900x24" bash`
RUN ${PIP} install --upgrade --ignore-installed "gym[atari,box2d,classic_control]" 
	# "gym[mujoco,robotics]"

# OpenAI baselines
RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt install -y \
		cmake \
		libopenmpi-dev \
		${PYTHON}-dev \
		zlib1g-dev

RUN git clone https://github.com/openai/baselines.git \
	&& ${PIP} install -e baselines \
	&& ${PIP} install pytest

# OpenAI Spinning Up https://spinningup.openai.com
RUN git clone https://github.com/openai/spinningup.git \
	&& ${PIP} install -e spinningup

# Create python3 fiendly catkin workspace
ENV CATKIN_PY3_WS=/catkin_build_ws
RUN mkdir ${CATKIN_PY3_WS} \
	&& cd ${CATKIN_PY3_WS} \
	&& catkin config -DPYTHON_EXECUTABLE=/usr/bin/python3 \
			-DPYTHON_INCLUDE_DIR=/usr/include/python3.6m \
			-DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.6m.so \
	&& catkin config --install
WORKDIR ${CATKIN_PY3_WS}

RUN mkdir ${CATKIN_PY3_WS}/src \
	&& cd ${CATKIN_PY3_WS}/src \
	&& git clone -b melodic https://github.com/ros-perception/vision_opencv.git \
	&& cd ${CATKIN_PY3_WS} \
	&& . /opt/ros/${ROS_DISTRO}/setup.sh \
	&& catkin build cv_bridge 

ADD ./ros_python3_issues /ros_python3_issues
ADD ./docker/ros_app.sh /ros_app.sh

ENTRYPOINT ["/ros_app.sh"]

CMD ["bash", "-c", "source /etc/bash.bashrc && jupyter notebook --notebook-dir=/tf --ip 0.0.0.0 --no-browser --allow-root"]
