#!/bin/bash

# docker compose -f dc_run.yml up -d fp-nvhpc-cc86-linux-amd64
docker compose -f dc_run.yml up -d fp-nvhpc-cc70-linux-ppc64le

# docker container exec -it fp-nvhpc-cc86 /bin/bash
docker container exec -it fp-nvhpc-cc70 /bin/bash