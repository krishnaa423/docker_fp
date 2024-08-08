#!/bin/bash

docker compose -f dc_run.yml up -d fp-mpich-gpu-cc86-linux-amd64

docker container exec -it fp-mpich-gpu-cc86 /bin/bash