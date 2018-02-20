# FROM plumbee/nvidia-virtualgl:latest
ARG from
FROM ${from}
# nvidia/opengl:1.0-glvnd-runtime

RUN apt-get update
RUN apt-get install -y apt-utils wget
RUN wget --quiet http://packages.osrfoundation.org/gazebo.key -O - | apt-key add - \
	&& sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable xenial main" > /etc/apt/sources.list.d/gazebo-stable.list' \
	&& apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get -y --quiet --no-install-recommends install \
		gazebo9 \
    libgazebo9 \
    libsdformat6 \
    gazebo9-common

RUN apt-get install -y firefox dbus

# # Borrowed from plumbee/nvidia-virtualgl
# ENV VIRTUALGL_VERSION 2.5.2

# # install VirtualGL
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     libglu1-mesa-dev mesa-utils curl ca-certificates xterm && \
#     curl -sSL https://downloads.sourceforge.net/project/virtualgl/"${VIRTUALGL_VERSION}"/virtualgl_"${VIRTUALGL_VERSION}"_amd64.deb -o virtualgl_"${VIRTUALGL_VERSION}"_amd64.deb && \
#     dpkg -i virtualgl_*_amd64.deb && \
#     /opt/VirtualGL/bin/vglserver_config -config +s +f -t && \
#     rm virtualgl_*_amd64.deb && \
#     apt-get clean && \
#     apt-get remove -y curl ca-certificates && \
#     rm -rf /var/lib/apt/lists/*


CMD ["vglrun", "gazebo"]