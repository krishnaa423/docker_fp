#!/bin/bash

docker compose -f dc_run.yml up -d fp-mpich-linux-amd64

docker container exec -it fp-mpich /bin/bash