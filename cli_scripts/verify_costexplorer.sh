#!/usr/bin/env bash
set -e

# Example: fetch cost for last day
YEST=$(date -d "yesterday" +%Y-%m-%d)
TODAY=$(date +%Y-%m-%d)

aws ce get-cost-and-usage \
  --time-period Start=$YEST,End=$TODAY \
  --granularity DAILY \
  --metrics UnblendedCost \
  --output json

