#!/usr/bin/env bash
set -e

TOPIC_NAME="CloudCostAlert"
TOPIC_ARN=$(aws sns create-topic --name $TOPIC_NAME --query 'TopicArn' --output text)
echo "SNS Topic ARN: $TOPIC_ARN"

# You must manually confirm email subscription after this
aws sns subscribe \
  --topic-arn $TOPIC_ARN \
  --protocol email \
  --notification-endpoint srivastavayushmaan1347@gmail.com

echo "✅ SNS setup done. Confirm subscription from email."
echo "Use this SNS_TOPIC_ARN: $TOPIC_ARN"

