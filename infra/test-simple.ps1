Param(
  [string]$Endpoint = 'http://localhost:4566'
)

Write-Host "=== Teste Simples - LocalStack ===" -ForegroundColor Cyan
Write-Host ""

# Verificar se LocalStack esta rodando
Write-Host "1. Verificando LocalStack..." -ForegroundColor Yellow
try {
  $health = Invoke-WebRequest -Uri "$Endpoint/_localstack/health" -UseBasicParsing -ErrorAction Stop
  Write-Host "   OK LocalStack esta rodando!" -ForegroundColor Green
} catch {
  Write-Error "LocalStack nao esta respondendo. Execute: docker-compose up -d"
  exit 1
}

# Listar buckets via HTTP
Write-Host "2. Listando buckets S3..." -ForegroundColor Yellow
try {
  $response = Invoke-WebRequest -Uri "$Endpoint/" -Method GET -UseBasicParsing -ErrorAction SilentlyContinue
  if ($response.Content -match 'ingestor-raw') {
    Write-Host "   OK Bucket ingestor-raw existe" -ForegroundColor Green
  }
  if ($response.Content -match 'ingestor-processed') {
    Write-Host "   OK Bucket ingestor-processed existe" -ForegroundColor Green
  }
} catch {
  Write-Host "   Buckets podem nao existir ainda" -ForegroundColor Yellow
}

# Verificar tabela DynamoDB via HTTP
Write-Host "3. Verificando DynamoDB..." -ForegroundColor Yellow
$headers = @{
  'Content-Type' = 'application/x-amz-json-1.0'
  'X-Amz-Target' = 'DynamoDB_20120810.ListTables'
}
try {
  $response = Invoke-RestMethod -Uri "$Endpoint/" -Method POST -Headers $headers -Body '{}' -ErrorAction Stop
  if ($response.TableNames -contains 'files') {
    Write-Host "   OK Tabela 'files' existe" -ForegroundColor Green
  } else {
    Write-Host "   Tabela 'files' nao encontrada" -ForegroundColor Yellow
  }
} catch {
  Write-Host "   Erro ao verificar DynamoDB: $_" -ForegroundColor Yellow
}

# Verificar Lambdas
Write-Host "4. Verificando Lambdas..." -ForegroundColor Yellow
try {
  $response = Invoke-RestMethod -Uri "$Endpoint/2015-03-31/functions" -Method GET -ErrorAction SilentlyContinue
  if ($response.Functions) {
    $lambdas = $response.Functions | ForEach-Object { $_.FunctionName }
    Write-Host "   Lambdas encontradas: $($lambdas -join ', ')" -ForegroundColor Gray
    if ($lambdas -contains 'ingest') {
      Write-Host "   OK Lambda 'ingest' existe" -ForegroundColor Green
    }
    if ($lambdas -contains 'files-api') {
      Write-Host "   OK Lambda 'files-api' existe" -ForegroundColor Green
    }
  }
} catch {
  Write-Host "   Erro ao listar Lambdas" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Diagnostico completo ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANTE: Para testar completamente o pipeline, instale awslocal:" -ForegroundColor Yellow
Write-Host "  pip install awscli-local" -ForegroundColor White
Write-Host ""
Write-Host "OU instale AWS CLI v2:" -ForegroundColor Yellow  
Write-Host "  winget install Amazon.AWSCLI" -ForegroundColor White
