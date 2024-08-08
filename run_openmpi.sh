#!/bin/bash

docker compose -f dc_run.yml up -d fp-openmpi-cpu-linux-amd64

docker container exec -it fp-openmpi-cpu /bin/bash