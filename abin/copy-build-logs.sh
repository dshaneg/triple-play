#! /bin/bash

# since the application build is running as part of the docker build,
# we want to pull out the build logs so that we can store them in the artifact repository.

docker create --name double-tap-copy-logs double-tap:build
docker cp double-tap-copy-logs:/app/build_logs .
docker rm -v double-tap-copy-logs
