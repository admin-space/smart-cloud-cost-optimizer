#!/usr/bin/env bash
set -e

TABLE_NAME="CloudUsageData"

aws dynamodb create-table \
  --table-name $TABLE_NAME \
  --attribute-definitions AttributeName=Date,AttributeType=S \
  --key-schema AttributeName=Date,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

echo "✅ DynamoDB table $TABLE_NAME created."

