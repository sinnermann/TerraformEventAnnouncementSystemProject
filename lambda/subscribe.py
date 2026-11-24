import json
import os
import boto3

sns = boto3.client("sns")
TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]

def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body") or "{}")
        email = body.get("email", "").strip()

        if not email:
            return response(400, {"message": "Email address is required."})

        sns.subscribe(
            TopicArn=TOPIC_ARN,
            Protocol="email",
            Endpoint=email
        )

        return response(200, {
            "message": f"Confirmation email sent to {email}! Please check your inbox and click 'Confirm subscription'."
        })
    except Exception as e:
        return response(500, {"message": f"Error: {str(e)}"})

def response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body)
    }
