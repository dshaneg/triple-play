#! /bin/bash

set -eo pipefail

# NOTE
# The robot that runs this script needs to export the following environment variables:
# - APP_VERSION: set to the tag name of the image you want to deploy
# - STAGE: set to the proper stage name--drives which configuration file overides you get. See ./config directory (e.g. cert, prod, etc.)
OWNER=dshaneg # probably should drive this value from the robot

APP_NAME=double-tap

# set APP_VERSION to default value if not set already--robots should set this value before calling
source abin/ensure-env-vars.sh

# if you're installing in a local stage (i.e. from your box),
# we'll include your user name in the helm release name
if [[ -z ${STAGE} ]]; then
  echo "WARNING: STAGE environment variable not set. Setting STAGE to 'local'. Robots should set STAGE to a valid value (e.g. cert, prod, etc.)."
  export STAGE=local
  export INSTANCE=${STAGE}-$(id -un)
else
  export INSTANCE=${STAGE}
fi

# determine which namespace to use. I'd rather do this via the config files...
if [[ ${STAGE} == 'prod' ]]; then
  NAMESPACE=prod
else
  NAMESPACE=default
fi

set -x

helm upgrade --install \
  --namespace ${NAMESPACE} \
  --values config/${STAGE}.yaml \
  --set docker.tag=${APP_VERSION} \
  --set meta.stage=${STAGE} \
  --set meta.instance=${INSTANCE} \
  --set meta.owner=${OWNER} \
  ${APP_NAME}-${INSTANCE} \
  double-tap-${CHART_VERSION}.tgz
