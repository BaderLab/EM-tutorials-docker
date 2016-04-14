#!/bin/bash

#before running this script you need to build the docker container.  Run the following command:
# docker build -t emtutorial/emtutorial . (in the directory containing the Dockerfile for EM tutorial)

eval `docker-machine env default`
#launch the EM tutuorial container
docker run --rm -it -p 8888:8888  --add-host="localhost:192.168.0.10" -v "$(pwd)/notebooks:/home/jovyan/work" emtutorial/emtutorial
