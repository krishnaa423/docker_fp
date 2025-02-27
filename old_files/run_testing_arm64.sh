#!/bin/bash

docker compose -f dc_run.yml up -d fp-testing-arm64

docker container exec -it fp-testing-arm64 /bin/bash