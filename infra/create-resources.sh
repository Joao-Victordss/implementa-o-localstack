#!/usr/bin/env bash
set -euo pipefail

# Script para criar buckets, tabela e deploy básico das lambdas no LocalStack usando awslocal (ou aws com endpoint-url)
AWS_ENDPOINT=${LOCALSTACK_ENDPOINT:-http://localhost:4566}

echo "Creating S3 buckets..."
awslocal s3 mb s3://ingestor-raw || true
awslocal s3 mb s3://ingestor-processed || true

echo "Creating DynamoDB table 'files'..."
awslocal dynamodb create-table \
  --table-name files \
  --attribute-definitions AttributeName=pk,AttributeType=S \
  --key-schema AttributeName=pk,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST || true

# Optionally create other resources

echo "Resources created"
