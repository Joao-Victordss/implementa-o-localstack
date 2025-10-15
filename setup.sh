#!/bin/bash

echo "🚀 Iniciando setup completo do projeto..."

# Verificar se o Docker está rodando
echo ""
echo "1️⃣ Verificando Docker..."
if ! docker ps > /dev/null 2>&1; then
    echo "❌ Docker não está rodando. Por favor, inicie o Docker Desktop."
    exit 1
fi
echo "✅ Docker está rodando"

# Iniciar LocalStack
echo ""
echo "2️⃣ Iniciando LocalStack..."
docker-compose up -d
sleep 5
echo "✅ LocalStack iniciado"

# Instalar dependências do backend
echo ""
echo "3️⃣ Instalando dependências do backend..."
cd backend
npm install
echo "✅ Dependências do backend instaladas"

# Instalar dependências do frontend
echo ""
echo "4️⃣ Instalando dependências do frontend..."
cd ../frontend
npm install
echo "✅ Dependências do frontend instaladas"

echo ""
echo "✅ Setup completo!"
echo ""
echo "Para iniciar o sistema:"
echo "1. Backend: cd backend && npm run start:dev"
echo "2. Frontend: cd frontend && npm run dev"
echo ""
echo "Acesse: http://localhost:3000"
