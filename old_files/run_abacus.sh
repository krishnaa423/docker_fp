#!/bin/bash

docker compose -f dc_run.yml up -d fp-abacus-linux-amd64

docker container exec -it fp-abacus /bin/bash