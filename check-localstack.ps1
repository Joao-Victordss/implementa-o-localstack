# Script para verificar e configurar LocalStack

Write-Host "🔍 Verificando configuração do LocalStack..." -ForegroundColor Cyan
Write-Host ""

# Verificar se o LocalStack está rodando
Write-Host "Verificando se o LocalStack está rodando..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:4566/_localstack/health" -UseBasicParsing -ErrorAction Stop
    Write-Host "✅ LocalStack está rodando!" -ForegroundColor Green
    
    # Mostrar serviços disponíveis
    $health = $response.Content | ConvertFrom-Json
    Write-Host ""
    Write-Host "Serviços disponíveis:" -ForegroundColor Cyan
    Write-Host "- S3: $($health.services.s3)" -ForegroundColor White
    Write-Host "- DynamoDB: $($health.services.dynamodb)" -ForegroundColor White
} catch {
    Write-Host "❌ LocalStack não está rodando." -ForegroundColor Red
    Write-Host ""
    Write-Host "Para iniciar o LocalStack, execute:" -ForegroundColor Yellow
    Write-Host "  docker-compose up -d" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "📊 Verificando recursos criados..." -ForegroundColor Cyan

# Verificar bucket S3
Write-Host ""
Write-Host "Buckets S3:" -ForegroundColor Yellow
try {
    $env:AWS_ACCESS_KEY_ID = "test"
    $env:AWS_SECRET_ACCESS_KEY = "test"
    $buckets = aws --endpoint-url=http://localhost:4566 s3 ls 2>&1
    if ($buckets -match "my-app-bucket") {
        Write-Host "✅ Bucket 'my-app-bucket' encontrado" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Bucket 'my-app-bucket' não encontrado (será criado ao iniciar o backend)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "ℹ️  AWS CLI não instalado (opcional para verificação manual)" -ForegroundColor Gray
}

# Verificar tabela DynamoDB
Write-Host ""
Write-Host "Tabelas DynamoDB:" -ForegroundColor Yellow
try {
    $tables = aws --endpoint-url=http://localhost:4566 dynamodb list-tables 2>&1
    if ($tables -match "users") {
        Write-Host "✅ Tabela 'users' encontrada" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Tabela 'users' não encontrada (será criada ao iniciar o backend)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "ℹ️  AWS CLI não instalado (opcional para verificação manual)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "✅ Verificação completa!" -ForegroundColor Green
Write-Host ""
Write-Host "LocalStack Dashboard: http://localhost:4566" -ForegroundColor Cyan
Write-Host ""
