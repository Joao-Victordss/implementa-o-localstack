# Script PowerShell para Windows

Write-Host "🚀 Iniciando setup completo do projeto..." -ForegroundColor Green

# Verificar se o Docker está rodando
Write-Host ""
Write-Host "1️⃣ Verificando Docker..." -ForegroundColor Cyan
try {
    docker ps | Out-Null
    Write-Host "✅ Docker está rodando" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker não está rodando. Por favor, inicie o Docker Desktop." -ForegroundColor Red
    exit 1
}

# Iniciar LocalStack
Write-Host ""
Write-Host "2️⃣ Iniciando LocalStack..." -ForegroundColor Cyan
docker-compose up -d
Start-Sleep -Seconds 5
Write-Host "✅ LocalStack iniciado" -ForegroundColor Green

# Instalar dependências do backend
Write-Host ""
Write-Host "3️⃣ Instalando dependências do backend..." -ForegroundColor Cyan
Set-Location backend
npm install
Write-Host "✅ Dependências do backend instaladas" -ForegroundColor Green

# Instalar dependências do frontend
Write-Host ""
Write-Host "4️⃣ Instalando dependências do frontend..." -ForegroundColor Cyan
Set-Location ..\frontend
npm install
Write-Host "✅ Dependências do frontend instaladas" -ForegroundColor Green

Set-Location ..

Write-Host ""
Write-Host "✅ Setup completo!" -ForegroundColor Green
Write-Host ""
Write-Host "Para iniciar o sistema:" -ForegroundColor Yellow
Write-Host "1. Backend: cd backend; npm run start:dev" -ForegroundColor White
Write-Host "2. Frontend: cd frontend; npm run dev" -ForegroundColor White
Write-Host ""
Write-Host "Acesse: http://localhost:3000" -ForegroundColor Cyan
