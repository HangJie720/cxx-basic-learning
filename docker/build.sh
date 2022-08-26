#! /bin/bash
docker build \
	-t nvidia-torch:min-18.04 \
       	-f ./Dockerfile \
	.
