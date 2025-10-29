#!/usr/bin/env bash
set -euo pipefail

# Deploy lambdas to LocalStack using awslocal
# Requires: zip, awslocal

LAMBDA_ROLE_ARN="arn:aws:iam::000000000000:role/lambda-ex"
LOCALSTACK_ENDPOINT=${LOCALSTACK_ENDPOINT:-http://localhost:4566}

function deploy() {
  local name=$1
  local folder=$2
  local handler=$3

  pushd "$folder" >/dev/null
  zip -r ../${name}.zip .
  popd >/dev/null

  awslocal lambda create-function --function-name ${name} \
    --runtime nodejs18.x \
    --handler ${handler} \
    --zip-file fileb://${folder}/../${name}.zip \
    --role ${LAMBDA_ROLE_ARN} || true
}

# Deploy ingest lambda
deploy ingest infra/lambdas/ingest index.handler

# Deploy api lambda
deploy files-api infra/lambdas/api index.handler

# Add S3 notification to trigger ingest lambda
awslocal s3api put-bucket-notification-configuration --bucket ingestor-raw --notification-configuration ' {
  "LambdaFunctionConfigurations": [
    {
      "LambdaFunctionArn": "arn:aws:lambda:us-east-1:000000000000:function:ingest",
      "Events": ["s3:ObjectCreated:*"]
    }
  ]
}' || true

# Add permission for s3 to invoke lambda
awslocal lambda add-permission --function-name ingest --principal s3.amazonaws.com --statement-id s3invoke || true

# Create API Gateway HTTP API (simple integration)
API_ID=$(awslocal apigatewayv2 create-api --name files-api --protocol-type HTTP --query 'ApiId' --output text || true)

if [ -n "$API_ID" ]; then
  echo "API created: $API_ID"
  # create integration
  INTEGRATION_ID=$(awslocal apigatewayv2 create-integration --api-id $API_ID --integration-type AWS_PROXY --integration-uri arn:aws:lambda:us-east-1:000000000000:function:files-api --payload-format-version 2.0 --query 'IntegrationId' --output text)
  awslocal apigatewayv2 create-route --api-id $API_ID --route-key "GET /files" --target integrations/$INTEGRATION_ID || true
  awslocal apigatewayv2 create-route --api-id $API_ID --route-key "GET /files/{id}" --target integrations/$INTEGRATION_ID || true
  awslocal apigatewayv2 create-stage --api-id $API_ID --stage-name v1 --auto-deploy
  echo "API deployed at: http://localhost:4566/restapis/$API_ID/v1/_user_request_"
fi


echo "Deployment finished"
