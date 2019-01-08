#!/bin/bash

set -eo pipefail

source abin/ensure-version-vars.sh

echo "Linting nodejs source..."
npm run lint --silent | tee build_logs/lint.log

echo "Running unit tests..."
npm run test --silent | tee build_logs/unit-test.log


