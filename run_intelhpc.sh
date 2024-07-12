#!/bin/bash

docker compose -f dc_run.yml up -d fp-intelhpc-linux-amd64

docker container exec -it fp-intelhpc /bin/bash