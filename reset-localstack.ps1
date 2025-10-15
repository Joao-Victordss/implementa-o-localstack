Write-Host "Resetando LocalStack completamente..." -ForegroundColor Cyan
Write-Host ""

# 1. Parar containers
Write-Host "1. Parando containers..." -ForegroundColor Yellow
docker-compose down -v 2>$null
Write-Host "   OK - Containers parados" -ForegroundColor Green

# 2. Remover containers LocalStack antigos
Write-Host ""
Write-Host "2. Removendo containers antigos..." -ForegroundColor Yellow
docker ps -a --filter "name=localstack" -q | ForEach-Object { docker rm -f $_ 2>$null }
Write-Host "   OK - Containers removidos" -ForegroundColor Green

# 3. Limpar volumes
Write-Host ""
Write-Host "3. Limpando volumes..." -ForegroundColor Yellow
docker volume prune -f 2>$null
Write-Host "   OK - Volumes limpos" -ForegroundColor Green

# 4. Remover pasta de dados local
Write-Host ""
Write-Host "4. Removendo dados locais..." -ForegroundColor Yellow
if (Test-Path ".\localstack-data") {
    Remove-Item -Recurse -Force ".\localstack-data" 2>$null
    Write-Host "   OK - Dados locais removidos" -ForegroundColor Green
} else {
    Write-Host "   INFO - Pasta de dados nao existe" -ForegroundColor Cyan
}

# 5. Limpar sistema Docker
Write-Host ""
Write-Host "5. Limpando sistema Docker..." -ForegroundColor Yellow
docker system prune -f 2>$null
Write-Host "   OK - Sistema limpo" -ForegroundColor Green

# 6. Aguardar
Write-Host ""
Write-Host "Aguardando 3 segundos..." -ForegroundColor Yellow
Start-Sleep -Seconds 3

# 7. Iniciar novamente
Write-Host ""
Write-Host "6. Iniciando LocalStack..." -ForegroundColor Yellow
docker-compose up -d

# 8. Aguardar inicializacao
Write-Host ""
Write-Host "Aguardando LocalStack inicializar (30 segundos)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# 9. Verificar status
Write-Host ""
Write-Host "7. Verificando status..." -ForegroundColor Yellow
$containers = docker ps --filter "name=localstack"
if ($containers) {
    Write-Host "   OK - LocalStack esta rodando!" -ForegroundColor Green
    
    # Testar conexao
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:4566/_localstack/health" -UseBasicParsing -TimeoutSec 10
        Write-Host ""
        Write-Host "8. Testando conexao..." -ForegroundColor Yellow
        Write-Host "   OK - LocalStack respondendo! Status: $($response.StatusCode)" -ForegroundColor Green
        
        # Mostrar servicos
        $health = Invoke-RestMethod -Uri "http://localhost:4566/_localstack/health"
        Write-Host ""
        Write-Host "Servicos disponiveis:" -ForegroundColor Cyan
        $health.services.PSObject.Properties | ForEach-Object {
            $status = if ($_.Value -eq "available") { "OK" } else { "ERRO" }
            Write-Host "   $status - $($_.Name): $($_.Value)" -ForegroundColor $(if ($_.Value -eq "available") { "Green" } else { "Red" })
        }
    } catch {
        Write-Host "   AVISO - LocalStack ainda nao esta respondendo" -ForegroundColor Yellow
        Write-Host "   DICA - Aguarde mais alguns segundos e teste manualmente" -ForegroundColor Cyan
    }
} else {
    Write-Host "   ERRO - LocalStack nao esta rodando" -ForegroundColor Red
    Write-Host ""
    Write-Host "Logs do Docker:" -ForegroundColor Yellow
    docker-compose logs --tail=20
}

Write-Host ""
Write-Host "Reset concluido!" -ForegroundColor Green
Write-Host ""
Write-Host "Proximos passos:" -ForegroundColor Cyan
Write-Host "   1. Verifique os logs: docker-compose logs -f" -ForegroundColor White
Write-Host "   2. Inicie o backend em novo terminal: cd backend; npm run start:dev" -ForegroundColor White
Write-Host "   3. Inicie o frontend em novo terminal: cd frontend; npm run dev" -ForegroundColor White
