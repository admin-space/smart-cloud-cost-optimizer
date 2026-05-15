#!/usr/bin/env bash
set -e

FUNCTION_NAME="cost-analyzer"
RULE_NAME="DailyCostCheck"
REGION=$(aws configure get region)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# 1️⃣ Create a CloudWatch rule to run every day
aws events put-rule \
  --name "$RULE_NAME" \
  --schedule-expression "rate(1 day)" \
  --region "$REGION"

# 2️⃣ Allow CloudWatch to trigger the Lambda
aws lambda add-permission \
  --function-name "$FUNCTION_NAME" \
  --statement-id "EventInvokePermission" \
  --action "lambda:InvokeFunction" \
  --principal events.amazonaws.com \
  --source-arn "arn:aws:events:$REGION:$ACCOUNT_ID:rule/$RULE_NAME" \
  --region "$REGION" || echo "ℹ️ Permission may already exist, continuing..."

# 3️⃣ Add Lambda as a target for the rule
aws events put-targets \
  --rule "$RULE_NAME" \
  --targets "Id"="1","Arn"="$(aws lambda get-function --function-name $FUNCTION_NAME --query 'Configuration.FunctionArn' --output text)" \
  --region "$REGION"

echo "✅ CloudWatch Event Rule Set to Trigger Lambda Daily"

