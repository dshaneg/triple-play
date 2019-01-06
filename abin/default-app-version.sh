#! /bin/bash

# dot (source) this file in to scripts that need to have a default app_version set when running locally

if [ -f ${APP_VERSION} ]; then
  echo "WARNING: APP_VERSION environment variable not set. Defaulting to 'latest'. Robots should set APP_VERSION to a valid SemVer string."
  APP_VERSION=latest
fi