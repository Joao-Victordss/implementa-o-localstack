Param(
  [string]$Endpoint = 'http://localhost:4566'
)

Write-Host "Creating S3 buckets..." -ForegroundColor Yellow

$awslocal = Get-Command awslocal -ErrorAction SilentlyContinue
$aws = Get-Command aws -ErrorAction SilentlyContinue

if ($awslocal) {
  & awslocal s3 mb s3://ingestor-raw 2>&1 | Out-Null
  & awslocal s3 mb s3://ingestor-processed 2>&1 | Out-Null
  Write-Host "  OK Buckets S3 criados/existem" -ForegroundColor Green
} elseif ($aws) {
  & aws --endpoint-url $Endpoint s3 mb s3://ingestor-raw 2>&1 | Out-Null
  & aws --endpoint-url $Endpoint s3 mb s3://ingestor-processed 2>&1 | Out-Null
  Write-Host "  OK Buckets S3 criados/existem" -ForegroundColor Green
} else {
  Write-Warning "AWS CLI ou awslocal nao encontrado. Instale: pip install awscli-local"
}

Write-Host "Creating DynamoDB table 'files'..." -ForegroundColor Yellow

if ($awslocal) {
  & awslocal dynamodb create-table --table-name files --attribute-definitions AttributeName=pk,AttributeType=S --key-schema AttributeName=pk,KeyType=HASH --billing-mode PAY_PER_REQUEST 2>&1 | Out-Null
  Write-Host "  OK Tabela 'files' criada/existe" -ForegroundColor Green
} elseif ($aws) {
  & aws --endpoint-url $Endpoint dynamodb create-table --table-name files --attribute-definitions AttributeName=pk,AttributeType=S --key-schema AttributeName=pk,KeyType=HASH --billing-mode PAY_PER_REQUEST 2>&1 | Out-Null
  Write-Host "  OK Tabela 'files' criada/existe" -ForegroundColor Green
} else {
  Write-Warning "AWS CLI ou awslocal nao encontrado."
}

Write-Host ""
Write-Host "Recursos criados. LocalStack endpoint: $Endpoint" -ForegroundColor Cyan