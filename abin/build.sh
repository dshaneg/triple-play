#!/bin/bash

set -eo pipefail

echo "Linting nodejs source..."
npm run lint --silent | tee build_logs/lint.log

echo "Running unit tests..."
npm run test --silent | tee build_logs/unit-test.log

