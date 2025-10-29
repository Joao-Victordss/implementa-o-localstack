Param(
  [string]$Endpoint = 'http://localhost:4566',
  [string]$TestFile = 'test-file.txt'
)

Write-Host "=== File Ingestor - Teste Automatizado ===" -ForegroundColor Cyan
Write-Host ""

# Verificar se AWS CLI ou awslocal esta disponivel
$awslocal = Get-Command awslocal -ErrorAction SilentlyContinue
$aws = Get-Command aws -ErrorAction SilentlyContinue

if (-not $awslocal -and -not $aws) {
  Write-Error "AWS CLI ou awslocal nao encontrado. Instale um deles para rodar este teste."
  exit 1
}

$awsCmd = if ($awslocal) { 'awslocal' } else { 'aws' }
$endpointArg = if ($awsCmd -eq 'aws') { @('--endpoint-url', $Endpoint) } else { @() }

# Criar arquivo de teste
Write-Host "1. Criando arquivo de teste..." -ForegroundColor Yellow
"Este e um arquivo de teste para o File Ingestor LocalStack.`nTimestamp: $(Get-Date)" | Out-File -FilePath $TestFile -Encoding UTF8

# Upload para bucket ingestor-raw
Write-Host "2. Upload para bucket ingestor-raw..." -ForegroundColor Yellow
$key = "test/$(Get-Date -Format 'yyyyMMdd-HHmmss')-$TestFile"
& $awsCmd @endpointArg s3 cp $TestFile "s3://ingestor-raw/$key" 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
  Write-Host "   OK Arquivo enviado: $key" -ForegroundColor Green
} else {
  Write-Error "Falha no upload"
  exit 1
}

# Aguardar processamento da Lambda
Write-Host "3. Aguardando Lambda processar (15s)..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Verificar item no DynamoDB
Write-Host "4. Verificando item no DynamoDB..." -ForegroundColor Yellow
$pk = "file#$key"
$itemJson = & $awsCmd @endpointArg dynamodb get-item --table-name files --key "{`"pk`":{`"S`":`"$pk`"}}" --output json 2>&1
if ($itemJson) {
  $item = $itemJson | ConvertFrom-Json
  if ($item.Item) {
    Write-Host "   OK Item encontrado no DynamoDB!" -ForegroundColor Green
    Write-Host "   PK: $($item.Item.pk.S)" -ForegroundColor Gray
    Write-Host "   Status: $($item.Item.status.S)" -ForegroundColor Gray
    if ($item.Item.checksum) {
      Write-Host "   Checksum: $($item.Item.checksum.S)" -ForegroundColor Gray
    }
    if ($item.Item.processedAt) {
      Write-Host "   ProcessedAt: $($item.Item.processedAt.S)" -ForegroundColor Gray
    }
  } else {
    Write-Warning "Item nao encontrado. Lambda pode nao ter sido disparada."
  }
}

# Verificar se arquivo foi movido para ingestor-processed
Write-Host "5. Verificando bucket ingestor-processed..." -ForegroundColor Yellow
$processedKey = "processed/$key"
$objects = & $awsCmd @endpointArg s3 ls "s3://ingestor-processed/$processedKey" 2>&1
if ($objects -match $TestFile) {
  Write-Host "   OK Arquivo encontrado em ingestor-processed!" -ForegroundColor Green
} else {
  Write-Warning "Arquivo nao encontrado em ingestor-processed."
}

# Listar todos os itens via API (se disponivel)
Write-Host "6. Testando API Gateway (GET /files)..." -ForegroundColor Yellow
$apisJson = & $awsCmd @endpointArg apigatewayv2 get-apis --output json 2>&1
if ($apisJson) {
  $apis = $apisJson | ConvertFrom-Json
  $apiId = ($apis.Items | Where-Object { $_.Name -eq 'files-api' } | Select-Object -First 1).ApiId
  
  if ($apiId) {
    $apiUrl = "http://localhost:4566/restapis/$apiId/v1/_user_request_/files"
    Write-Host "   API URL: $apiUrl" -ForegroundColor Gray
    $response = Invoke-WebRequest -Uri $apiUrl -Method GET -UseBasicParsing -ErrorAction SilentlyContinue
    if ($response) {
      $data = $response.Content | ConvertFrom-Json
      Write-Host "   OK API retornou $($data.items.Count) item(s)" -ForegroundColor Green
    }
  } else {
    Write-Warning "API Gateway nao encontrada."
  }
}

# Cleanup
Write-Host ""
Write-Host "7. Limpeza..." -ForegroundColor Yellow
Remove-Item $TestFile -ErrorAction SilentlyContinue
Write-Host "   OK Arquivo de teste removido" -ForegroundColor Green

Write-Host ""
Write-Host "=== Teste concluido ===" -ForegroundColor Cyan
Write-Host "Para ver logs detalhados: docker logs localstack-main --tail 100" -ForegroundColor Gray
