#!/bin/bash

docker compose -f dc_run.yml up -d fp-nvhpc-linux-amd64-cc86

docker container exec -it fp-nvhpc-cc86 /bin/bash