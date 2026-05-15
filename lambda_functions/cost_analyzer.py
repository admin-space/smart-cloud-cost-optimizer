import boto3
import os
from decimal import Decimal
from datetime import datetime, timedelta

# --------------------------
# Environment Variables
# --------------------------
SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")
DYNAMO_TABLE = os.environ.get("DYNAMO_TABLE")
COST_THRESHOLD = Decimal(os.environ.get("COST_THRESHOLD", "5"))

# --------------------------
# AWS Clients
# --------------------------
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(DYNAMO_TABLE)
sns = boto3.client('sns')
ce = boto3.client('ce')  # Cost Explorer

# --------------------------
# Lambda Handler
# --------------------------
def lambda_handler(event, context):
    try:
        # ----------------------
        # Get cost for yesterday
        # ----------------------
        today = datetime.utcnow().date()
        yesterday = today - timedelta(days=1)

        response = ce.get_cost_and_usage(
            TimePeriod={"Start": str(yesterday), "End": str(today)},
            Granularity="DAILY",
            Metrics=["BlendedCost"]
        )

        # Extract cost safely
        cost_str = response["ResultsByTime"][0]["Total"]["BlendedCost"]["Amount"]
        total_cost = Decimal(cost_str)

        # ----------------------
        # Store in DynamoDB
        # ----------------------
        item = {
            "Date": str(yesterday),
            "TotalCost": total_cost
        }
        table.put_item(Item=item)

        # ----------------------
        # Send SNS alert if cost exceeds threshold
        # ----------------------
        if total_cost > COST_THRESHOLD:
            message = f"⚠️ AWS Daily Cost Alert: ${total_cost} exceeds threshold of ${COST_THRESHOLD}"
            sns.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=message
            )

        # ----------------------
        # Temporary Test SNS (force email)
        # ----------------------
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Message="🚀 Test alert: Lambda -> SNS is working!"
        )

        return {
            "statusCode": 200,
            "body": f"✅ Cost analyzed successfully: ${total_cost}"
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": f"❌ Error: {str(e)}"
        }

