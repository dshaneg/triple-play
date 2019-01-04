#!/bin/bash
set -e

# If running locally, we won't necessarily have the APP_VERSION variable set,
# But the build machine should.
# BUT, most developers will not have permissions to push!
# though the versioned package will be created in the publish image
if [ -f ${APP_VERSION} ]; then
  echo "WARNING: APP_VERSION environment variable not set. Defaulting to 'latest'. Robots should set it to a valid SemVer string."
  APP_VERSION=latest
fi

echo "Tagging..."
CONTAINER_NAME=double-tap
REPOSITORY=dshaneg
APP_TAG=${REPOSITORY}/${CONTAINER_NAME}:${APP_VERSION}
BUILD_TAG=${APP_TAG}.build

echo "Tagging build image with ${BUILD_TAG}"
docker tag ${CONTAINER_NAME}:build ${BUILD_TAG}

echo "Tagging app image with ${APP_TAG}"
docker tag ${CONTAINER_NAME}:latest ${APP_TAG}

echo "Pushing ${BUILD_TAG}"
docker push ${BUILD_TAG}

echo "Pushing ${APP_TAG}"
docker push ${APP_TAG}
