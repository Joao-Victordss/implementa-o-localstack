Write-Host "Diagnostico do Sistema" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar Docker
Write-Host "1. Verificando Docker..." -ForegroundColor Yellow
try {
    docker --version
    Write-Host "   OK - Docker instalado" -ForegroundColor Green
} catch {
    Write-Host "   ERRO - Docker nao encontrado - Instale Docker Desktop" -ForegroundColor Red
    exit 1
}

# 2. Verificar se Docker esta rodando
Write-Host ""
Write-Host "2. Verificando se Docker esta rodando..." -ForegroundColor Yellow
$dockerRunning = docker ps 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK - Docker esta rodando" -ForegroundColor Green
} else {
    Write-Host "   ERRO - Docker nao esta rodando - Abra o Docker Desktop" -ForegroundColor Red
    exit 1
}

# 3. Verificar LocalStack
Write-Host ""
Write-Host "3. Verificando LocalStack..." -ForegroundColor Yellow
$localstackContainer = docker ps --filter "name=localstack" --format "{{.Names}}"
if ($localstackContainer) {
    Write-Host "   OK - Container LocalStack esta rodando: $localstackContainer" -ForegroundColor Green
} else {
    Write-Host "   ERRO - Container LocalStack NAO esta rodando" -ForegroundColor Red
    Write-Host "   DICA - Execute: docker-compose up -d" -ForegroundColor Yellow
    exit 1
}

# 4. Verificar porta 4566
Write-Host ""
Write-Host "4. Verificando porta 4566..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:4566/_localstack/health" -UseBasicParsing -TimeoutSec 5
    Write-Host "   OK - LocalStack respondendo na porta 4566" -ForegroundColor Green
    Write-Host "   Status HTTP: $($response.StatusCode)" -ForegroundColor Cyan
} catch {
    Write-Host "   ERRO - LocalStack nao esta respondendo na porta 4566" -ForegroundColor Red
    Write-Host "   DICA - Aguarde alguns segundos e tente novamente" -ForegroundColor Yellow
    exit 1
}

# 5. Verificar servicos
Write-Host ""
Write-Host "5. Verificando servicos LocalStack..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "http://localhost:4566/_localstack/health"
    
    if ($health.services.s3 -eq "available") {
        Write-Host "   OK - S3 disponivel" -ForegroundColor Green
    } else {
        Write-Host "   ERRO - S3 nao disponivel" -ForegroundColor Red
    }
    
    if ($health.services.dynamodb -eq "available") {
        Write-Host "   OK - DynamoDB disponivel" -ForegroundColor Green
    } else {
        Write-Host "   ERRO - DynamoDB nao disponivel" -ForegroundColor Red
    }
} catch {
    Write-Host "   AVISO - Nao foi possivel verificar servicos" -ForegroundColor Yellow
}

# 6. Verificar Node.js
Write-Host ""
Write-Host "6. Verificando Node.js..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version
    Write-Host "   OK - Node.js instalado: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "   ERRO - Node.js nao encontrado" -ForegroundColor Red
}

# 7. Verificar portas backend/frontend
Write-Host ""
Write-Host "7. Verificando portas da aplicacao..." -ForegroundColor Yellow
$port3001 = netstat -ano | Select-String ":3001"
$port3000 = netstat -ano | Select-String ":3000"

if ($port3001) {
    Write-Host "   OK - Porta 3001 (backend) em uso" -ForegroundColor Green
} else {
    Write-Host "   AVISO - Porta 3001 (backend) livre" -ForegroundColor Yellow
}

if ($port3000) {
    Write-Host "   OK - Porta 3000 (frontend) em uso" -ForegroundColor Green
} else {
    Write-Host "   AVISO - Porta 3000 (frontend) livre" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Diagnostico concluido!" -ForegroundColor Cyan
