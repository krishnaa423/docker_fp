#!/bin/bash

docker compose -f dc_run.yml up -d ubuntu

docker container exec -it ubuntu /bin/bash