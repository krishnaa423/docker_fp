#!/bin/bash

docker compose -f dc_run.yml up -d fp-testing

docker container exec -it fp-testing /bin/bash