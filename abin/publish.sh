#!/bin/bash

set -eo pipefail

# If running locally, we won't necessarily have the APP_VERSION variable set,
# But the build machine should.
# BUT, most developers will not have permissions to push!
# though the versioned package will be created in the publish image
source abin/ensure-version-vars.sh

echo "Tagging and publishing images..."

CONTAINER_NAME=triple-play
REPOSITORY=dshaneg
APP_TAG=${REPOSITORY}/${CONTAINER_NAME}:${APP_VERSION}
DEPLOY_TAG=${APP_TAG}.deploy
TEST_TAG=${APP_TAG}.test

set -x

docker tag ${CONTAINER_NAME}:deploy ${DEPLOY_TAG}
docker tag ${CONTAINER_NAME}:test ${TEST_TAG}
docker tag ${CONTAINER_NAME}:latest ${APP_TAG}

docker push ${DEPLOY_TAG}
docker push ${TEST_TAG}
docker push ${APP_TAG}
