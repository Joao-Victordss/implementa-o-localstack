Param()
$root = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $root

Write-Host "Parando LocalStack (docker-compose down)..."
docker-compose down

Write-Host "Feito. Feche as janelas do PowerShell abertas do backend/frontend se necessário."
