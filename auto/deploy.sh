#! /bin/bash

set -eo pipefail

# NOTE
# The robot that runs this script needs to export the following environment variables:
# APP_VERSION: set to the tag name of the image you want to deploy
# STAGE: set to the proper stage name--drives which configuration file overides you get. See ./config directory (e.g. cert, prod, etc.)

APP_NAME=double-tap
OWNER=dshaneg

# set APP_VERSION to default value if not set already--robots should set this value before calling
source auto/default-app-version.sh

# if you're installing in a local stage (i.e. from your box),
# we'll include your user name in the helm release name
if [[ -z ${STAGE} ]]; then
  echo "WARNING: STAGE environment variable not set. Setting STAGE to 'local'. Robots should set STAGE to a valid value (e.g. cert, prod, etc.)."
  export STAGE=local
  export INSTANCE=${STAGE}-$(id -un)
else
  export INSTANCE=${STAGE}
fi

set -x

# determine which namespace to use. I'd rather do this via the config files...
if [[ ${STAGE} == 'prod' ]]; then
  NAMESPACE=prod
else
  NAMESPACE=default
fi

# chart version requires semver
# If we aren't using latest as our version, then the chart version follows the app version
if [[ ${APP_VERSION} == 'latest' ]]; then
  CHART_VERSION=0.0.0
else
  CHART_VERSION=${APP_VERSION}
fi

# could just upgrade --install with the chart/double-tap directory name
# however, packaging it with the --app-version option populates the app version column
# in the helm list command with the current value of the APP_VERSION environment variable.
# In our case, it'd be nice if we could set an app-version option on helm upgrade...
helm package --version ${CHART_VERSION} --app-version ${APP_VERSION} chart/double-tap

helm upgrade --install \
  --namespace ${NAMESPACE} \
  --values config/${STAGE}.yaml \
  --set docker.tag=${APP_VERSION} \
  --set meta.stage=${STAGE} \
  --set meta.instance=${INSTANCE} \
  --set meta.owner=${OWNER} \
  ${APP_NAME}-${INSTANCE} \
  double-tap-${CHART_VERSION}.tgz
