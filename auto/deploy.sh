#! /bin/bash

APP_NAME=double-tap

if [[ -z ${STAGE} ]]; then
  echo "WARNING: STAGE environment variable not set. Setting STAGE to 'local'. If a robot is doing this, you need to set the variable."
  export STAGE=local
  export CHANNEL=${STAGE}-$(id -un)
else
  export CHANNEL=${STAGE}
fi

set -x

helm upgrade --install --values config/${STAGE}.yaml --set channel=${CHANNEL} ${APP_NAME}-${CHANNEL} ./chart/double-tap
