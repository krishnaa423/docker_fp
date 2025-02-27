#!/bin/bash

docker compose -f dc_run.yml up -d fp-testing-amd64

docker container exec -it fp-testing-amd64 /bin/bash