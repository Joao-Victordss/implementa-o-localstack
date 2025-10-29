Param(
  [switch]$SkipInstall,
  [switch]$SkipInfra
)

# Start-all: sobe LocalStack, cria recursos, deploy das lambdas, e inicia backend/frontend
$root = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $root

Write-Host "1) Subindo LocalStack (docker-compose up -d)..."
docker-compose up -d

# Esperar LocalStack iniciar minimamente
Write-Host "Aguardando LocalStack iniciar (10s)..."
Start-Sleep -Seconds 10

if (-not $SkipInfra) {
  Write-Host "2) Criando recursos (buckets/tabela) e deploy das lambdas..."
  Push-Location (Join-Path $root "infra")
  
  # If PowerShell scripts exist, prefer them
  if (Test-Path "./create-resources.ps1") {
    Write-Host "Executando PowerShell: create-resources.ps1"
    & "${PWD}\create-resources.ps1"
  } elseif (Test-Path "./create-resources.sh") {
    bash ./create-resources.sh
  }

  if (Test-Path "./deploy-lambdas.ps1") {
    Write-Host "Executando PowerShell: deploy-lambdas.ps1"
    & "${PWD}\deploy-lambdas.ps1"
  } elseif (Test-Path "./deploy-lambdas.sh") {
    bash ./deploy-lambdas.sh
  }
  
  Pop-Location
} else {
  Write-Host "Pulando criação de infra (--SkipInfra)"
}

# Backend
$backend = Join-Path $root "backend"
if (-not $SkipInstall) {
  Write-Host "3) Instalando dependências do backend..."
  Push-Location $backend
  npm install
  Pop-Location
}

Write-Host "Abrindo backend (npm run start:dev) em nova janela do PowerShell..."
Start-Process powershell -ArgumentList "-NoExit","-Command","cd '$backend'; npm run start:dev"

# Frontend
$frontend = Join-Path $root "frontend"
if (-not $SkipInstall) {
  Write-Host "4) Instalando dependências do frontend..."
  Push-Location $frontend
  npm install
  Pop-Location
}

Write-Host "Abrindo frontend (npm run dev) em nova janela do PowerShell..."
Start-Process powershell -ArgumentList "-NoExit","-Command","cd '$frontend'; npm run dev"

Write-Host "\nPronto. Frontend: http://localhost:3000  Backend: http://localhost:3001  LocalStack: http://localhost:4566"
Write-Host "Observação: se estiver no Windows e não tiver 'bash'/'awslocal', execute os scripts em WSL ou instale awslocal."
