# Ros Experiments 1

First experiments with ROS + gazebo on Mac + Docker in VM (VMWare Fusion or Hypervisor.framework)


## Run Gazebo in the docker container with remote X server

This setup uses VirtualGL for utilizing server's GPU, but streams UI to the client.

1. Start Docker daemon on the server
1. Configure DOCKER_HOST (e.g. `set -gx DOCKER_HOST 192.168.99.128:2375`)
1. Build gazebo-gl Docker image from this repo (e.g. using `docker-compose build gazebo`)
1. Install VirtualGL on your machine. It has support for all major desktop OSes, including Mac
1. Run `vglclient` on your machine (on my Mac it ended up in `/opt/VirtualGL/bin/vglclient`)
1. Run gazebo from docker using the `run_mac.sh` script 

Kudos to Plumbee [docker image](https://github.com/plumbee/nvidia-virtualgl) and this Medium article](https://medium.com/@pigiuz/hw-accelerated-gui-apps-on-docker-7fd424fe813e) that describe how to set this up.



