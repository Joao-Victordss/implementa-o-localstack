Param(
  [string]$Endpoint = 'http://localhost:4566'
)

$roleArn = 'arn:aws:iam::000000000000:role/lambda-ex'

$awslocal = Get-Command awslocal -ErrorAction SilentlyContinue
$aws = Get-Command aws -ErrorAction SilentlyContinue

if (-not $awslocal -and -not $aws) {
  Write-Error "AWS CLI ou awslocal nao encontrado. Instale: pip install awscli-local"
  exit 1
}

function New-LambdaZip($Name, $Folder) {
  $zipPath = Join-Path $Folder "..\${Name}.zip"
  if (Test-Path $zipPath) { Remove-Item $zipPath }
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [System.IO.Compression.ZipFile]::CreateFromDirectory($Folder, $zipPath)
  return $zipPath
}

$root = Split-Path -Parent $MyInvocation.MyCommand.Definition
Push-Location (Join-Path $root '..')

Write-Host "Deploying Lambda ingest..." -ForegroundColor Yellow
$zipIngest = New-LambdaZip 'ingest' 'infra/lambdas/ingest'
if ($awslocal) {
  & awslocal lambda create-function --function-name ingest --runtime nodejs18.x --handler index.handler --zip-file fileb://$zipIngest --role $roleArn 2>&1 | Out-Null
} else {
  & aws --endpoint-url $Endpoint lambda create-function --function-name ingest --runtime nodejs18.x --handler index.handler --zip-file fileb://$zipIngest --role $roleArn 2>&1 | Out-Null
}
Write-Host "  OK Lambda ingest criada" -ForegroundColor Green

Write-Host "Deploying Lambda files-api..." -ForegroundColor Yellow
$zipApi = New-LambdaZip 'files-api' 'infra/lambdas/api'
if ($awslocal) {
  & awslocal lambda create-function --function-name files-api --runtime nodejs18.x --handler index.handler --zip-file fileb://$zipApi --role $roleArn 2>&1 | Out-Null
} else {
  & aws --endpoint-url $Endpoint lambda create-function --function-name files-api --runtime nodejs18.x --handler index.handler --zip-file fileb://$zipApi --role $roleArn 2>&1 | Out-Null
}
Write-Host "  OK Lambda files-api criada" -ForegroundColor Green

Write-Host "Configurando S3 trigger..." -ForegroundColor Yellow
if ($awslocal) {
  & awslocal s3api put-bucket-notification-configuration --bucket ingestor-raw --notification-configuration file://infra/s3-notification.json 2>&1 | Out-Null
  & awslocal lambda add-permission --function-name ingest --principal s3.amazonaws.com --statement-id s3invoke --action lambda:InvokeFunction 2>&1 | Out-Null
} else {
  & aws --endpoint-url $Endpoint s3api put-bucket-notification-configuration --bucket ingestor-raw --notification-configuration file://infra/s3-notification.json 2>&1 | Out-Null
  & aws --endpoint-url $Endpoint lambda add-permission --function-name ingest --principal s3.amazonaws.com --statement-id s3invoke --action lambda:InvokeFunction 2>&1 | Out-Null
}
Write-Host "  OK S3 trigger configurado" -ForegroundColor Green

Write-Host "Criando API Gateway..." -ForegroundColor Yellow
if ($awslocal) {
  $api = (& awslocal apigatewayv2 create-api --name files-api --protocol-type HTTP --query ApiId --output text 2>&1) | Out-String
  $api = $api.Trim()
  if ($api -and $api -notmatch 'error') {
    $integration = (& awslocal apigatewayv2 create-integration --api-id $api --integration-type AWS_PROXY --integration-uri arn:aws:lambda:us-east-1:000000000000:function:files-api --payload-format-version 2.0 --query IntegrationId --output text 2>&1) | Out-String
    $integration = $integration.Trim()
    & awslocal apigatewayv2 create-route --api-id $api --route-key 'GET /files' --target integrations/$integration 2>&1 | Out-Null
    & awslocal apigatewayv2 create-route --api-id $api --route-key 'GET /files/{id}' --target integrations/$integration 2>&1 | Out-Null
    & awslocal apigatewayv2 create-stage --api-id $api --stage-name v1 --auto-deploy 2>&1 | Out-Null
    Write-Host "  OK API Gateway: http://localhost:4566/restapis/$api/v1/_user_request_/files" -ForegroundColor Green
  }
} else {
  $api = (& aws --endpoint-url $Endpoint apigatewayv2 create-api --name files-api --protocol-type HTTP --query ApiId --output text 2>&1) | Out-String
  $api = $api.Trim()
  if ($api -and $api -notmatch 'error') {
    $integration = (& aws --endpoint-url $Endpoint apigatewayv2 create-integration --api-id $api --integration-type AWS_PROXY --integration-uri arn:aws:lambda:us-east-1:000000000000:function:files-api --payload-format-version 2.0 --query IntegrationId --output text 2>&1) | Out-String
    $integration = $integration.Trim()
    & aws --endpoint-url $Endpoint apigatewayv2 create-route --api-id $api --route-key 'GET /files' --target integrations/$integration 2>&1 | Out-Null
    & aws --endpoint-url $Endpoint apigatewayv2 create-route --api-id $api --route-key 'GET /files/{id}' --target integrations/$integration 2>&1 | Out-Null
    & aws --endpoint-url $Endpoint apigatewayv2 create-stage --api-id $api --stage-name v1 --auto-deploy 2>&1 | Out-Null
    Write-Host "  OK API Gateway: http://localhost:4566/restapis/$api/v1/_user_request_/files" -ForegroundColor Green
  }
}

Pop-Location
Write-Host ""
Write-Host "Deploy concluido!" -ForegroundColor Cyan
