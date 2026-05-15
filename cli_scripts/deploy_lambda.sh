#!/usr/bin/env bash
set -e

ROLE_NAME="lambda-cost-optimizer-role"
ROLE_ARN=$(aws iam get-role --role-name $ROLE_NAME --query 'Role.Arn' --output text)
SNS_TOPIC_ARN="arn:aws:sns:ap-south-1:690788837898:CloudCostAlert"
DYNAMO_TABLE="CloudUsageData"
COST_THRESHOLD=5

FUNCTION_NAME="cost-analyzer"
FUNC_PY="../lambda_functions/cost_analyzer.py"
ZIP_FILE="cost_analyzer.zip"

# --------------------------
# Zip the Lambda function
# --------------------------
zip -j "$ZIP_FILE" "$FUNC_PY"

# --------------------------
# Create or Update Lambda
# --------------------------
aws lambda create-function \
    --function-name "$FUNCTION_NAME" \
    --runtime python3.9 \
    --role "$ROLE_ARN" \
    --handler "cost_analyzer.lambda_handler" \
    --zip-file "fileb://$ZIP_FILE" \
    --environment Variables="{SNS_TOPIC_ARN=$SNS_TOPIC_ARN,DYNAMO_TABLE=$DYNAMO_TABLE,COST_THRESHOLD=$COST_THRESHOLD}" \
    || aws lambda update-function-code \
        --function-name "$FUNCTION_NAME" \
        --zip-file "fileb://$ZIP_FILE"

echo "✅ Lambda $FUNCTION_NAME deployed successfully!"

