#!/bin/bash

docker compose -f dc_run.yml up -d fp-nvhpc-cc86-linux-amd64

docker container exec -it fp-nvhpc-cc86 /bin/bash