#!/bin/bash

set -eo pipefail

source abin/ensure-env-vars.sh

echo "Linting nodejs source..."
npm run lint --silent | tee build_logs/lint.log

echo "Running unit tests..."
npm run test --silent | tee build_logs/unit-test.log

echo "Linting helm chart..."
helm lint ./chart/double-tap

echo "Packaging helm chart..."
# could just deploy with upgrade --install with the chart/double-tap directory name
# however, packaging it with the --app-version option populates the app version column
# in the helm list command with the current value of the APP_VERSION environment variable.
# In our case, it'd be nice if we could set an app-version option on helm upgrade...
helm package --version ${CHART_VERSION} --app-version ${APP_VERSION} chart/double-tap | tee build_logs/helmlint.log
