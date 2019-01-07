#! /bin/bash

# dot (source) this file in to scripts that need to have a default app_version set when running locally

if [ -f ${APP_VERSION} ]; then
  echo "WARNING: APP_VERSION environment variable not set. Defaulting to 'latest'. Robots should set APP_VERSION to a valid SemVer string."
  APP_VERSION=latest
fi

# chart version requires semver
# If we aren't using latest as our version, then the chart version follows the app version
if [[ ${APP_VERSION} == 'latest' ]]; then
  CHART_VERSION=0.1.0
else
  CHART_VERSION=${APP_VERSION}
fi