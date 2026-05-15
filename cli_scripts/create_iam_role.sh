#!/usr/bin/env bash
set -e  # Exit immediately if any command fails

ROLE_NAME="lambda-cost-optimizer-role"

echo "⚡ Creating IAM role: $ROLE_NAME ..."

# 1️⃣ Create the role with trust policy for Lambda
aws iam create-role \
  --role-name $ROLE_NAME \
  --assume-role-policy-document file://<(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "lambda.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
)

echo "✅ Role $ROLE_NAME created successfully."

# 2️⃣ Attach necessary managed policies
POLICIES=(
  "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
  "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess"
  "arn:aws:iam::aws:policy/ReadOnlyAccess"
 
)

echo "⚡ Attaching managed policies ..."
for POLICY in "${POLICIES[@]}"; do
  aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn $POLICY
  echo "   ✔ Attached $POLICY"
done

echo "🎉 IAM role $ROLE_NAME is fully ready with all required policies."

