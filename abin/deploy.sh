#! /bin/bash

set -eo pipefail

# NOTE
# The robot that runs this script needs to export the following environment variables:
# - APP_VERSION: set to the tag name of the image you want to deploy
# - STAGE: set to the proper stage name--drives which configuration file overides you get. See ./config directory (e.g. cert, prod, etc.)
OWNER=dshaneg # probably should drive this value from the robot

APP_NAME=triple-play

# set APP_VERSION to default value if not set already--robots should set this value before calling
source abin/ensure-version-vars.sh

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

RELEASE=${APP_NAME}-${INSTANCE}

set -x

helm upgrade --install \
  --wait \
  --namespace ${NAMESPACE} \
  --values config/${STAGE}.yaml \
  --set docker.tag=${APP_VERSION} \
  --set meta.stage=${STAGE} \
  --set meta.instance=${INSTANCE} \
  --set meta.owner=${OWNER} \
  ${RELEASE} \
  triple-play-${CHART_VERSION}.tgz

# TODO: add --versbose if the feature ever gets completed.
# the --versbose option should show the output of the test command
# https://github.com/helm/helm/issues/1957
# once the verbose feature is working, the command should look like
# helm test ${RELEASE} --verbose --cleanup
# and the script following the helm test command should be able to be removed

set +e

helm test ${RELEASE}

set +x

test_pods=$(helm status ${RELEASE} -o json | jq -r .info.status.last_test_suite_run.results[].name)
namespace=$(helm status ${RELEASE} -o json | jq -r .namespace)

for test_pod in $test_pods; do
  echo "Test Pod: ${test_pod}"
  echo "============="
  echo ""
  kubectl -n ${namespace} logs ${test_pod}
  kubectl -n ${namespace} delete pod ${test_pod}
  echo ""
  echo "============="
done

