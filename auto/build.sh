#!/bin/sh
npm run lint --silent | tee build_logs/lint.log
npm run test --silent | tee build_logs/unit-test.log

