# 🚨 Guia de Resolução de Problemas

## Erro: ECONNREFUSED (LocalStack não está acessível)

### Sintomas
```
Error: connect ECONNREFUSED ::1:4566
Error: connect ECONNREFUSED 127.0.0.1:4566
```

### Solução Rápida

```powershell
# 1. Executar reset completo
.\reset-localstack.ps1

# 2. Aguardar 30 segundos

# 3. Verificar status
.\diagnose.ps1

# 4. Se tudo OK, iniciar backend
cd backend
npm run start:dev
```

---

## Erro: OSError [Errno 16] Device or resource busy

### Sintomas
```
OSError: [Errno 16] Device or resource busy: '/tmp/localstack'
```

### Solução

Este erro foi corrigido atualizando o `docker-compose.yml`. Execute:

```powershell
# 1. Parar tudo
docker-compose down -v

# 2. Remover dados antigos
Remove-Item -Recurse -Force .\localstack-data

# 3. Limpar Docker
docker system prune -f

# 4. Iniciar novamente
docker-compose up -d
```

---

## Checklist de Resolução

### 1. Docker está funcionando?

```powershell
# Verificar
docker --version
docker ps

# Se não funcionar
# → Abra o Docker Desktop e aguarde inicializar
```

### 2. LocalStack está rodando?

```powershell
# Verificar
docker ps --filter "name=localstack"

# Se não mostrar nada
docker-compose up -d
Start-Sleep -Seconds 30
```

### 3. LocalStack está respondendo?

```powershell
# Testar
curl http://localhost:4566/_localstack/health

# Deve retornar JSON com serviços
```

### 4. Arquivo .env está correto?

Verifique `backend/.env`:

```env
# IMPORTANTE: Use LOCALSTACK_ENDPOINT, não AWS_ENDPOINT
LOCALSTACK_ENDPOINT=http://localhost:4566
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test
DYNAMODB_TABLE_NAME=users
S3_BUCKET_NAME=my-app-bucket
JWT_SECRET=seu-segredo-aqui
JWT_EXPIRES_IN=24h
PORT=3001
```

### 5. Dependências instaladas?

```powershell
# Backend
cd backend
npm install

# Frontend
cd frontend
npm install
```

---

## Ordem Correta de Inicialização

```
1. Docker Desktop aberto e verde ✅
   ↓
2. docker-compose up -d ✅
   ↓
3. Aguardar 30 segundos ⏳
   ↓
4. .\diagnose.ps1 (verificar) 🔍
   ↓
5. cd backend && npm run start:dev 🚀
   ↓
6. cd frontend && npm run dev 🎨
   ↓
7. Abrir http://localhost:3000 🌐
```

---

## Comandos Úteis

### Ver logs do LocalStack
```powershell
docker-compose logs -f
```

### Reiniciar LocalStack
```powershell
docker-compose restart
```

### Reset completo
```powershell
.\reset-localstack.ps1
```

### Diagnóstico
```powershell
.\diagnose.ps1
```

### Parar tudo
```powershell
docker-compose down
```

### Parar tudo + limpar dados
```powershell
docker-compose down -v
Remove-Item -Recurse -Force .\localstack-data
```

---

## Erros Comuns do Backend

### ❌ "Cannot find module '@nestjs/common'"

**Solução:**
```powershell
cd backend
npm install
```

### ❌ "Port 3001 already in use"

**Solução:**
```powershell
# Encontrar processo
netstat -ano | findstr :3001

# Matar processo (substitua PID)
taskkill /PID <PID> /F
```

### ❌ Backend inicia mas não conecta ao LocalStack

**Solução:**
1. Verifique se LocalStack está rodando: `docker ps`
2. Teste: `curl http://localhost:4566/_localstack/health`
3. Verifique o `.env`: `LOCALSTACK_ENDPOINT=http://localhost:4566`
4. Reinicie o backend

---

## Erros Comuns do Frontend

### ❌ "Cannot find module 'next'"

**Solução:**
```powershell
cd frontend
npm install
```

### ❌ "Port 3000 already in use"

**Solução:**
```powershell
# Encontrar processo
netstat -ano | findstr :3000

# Matar processo (substitua PID)
taskkill /PID <PID> /F
```

### ❌ Frontend não consegue fazer requisições

**Solução:**
1. Verifique se o backend está rodando: `curl http://localhost:3001/auth/me`
2. Verifique o `.env.local`: `NEXT_PUBLIC_API_URL=http://localhost:3001`
3. Limpe o cache do navegador (Ctrl+Shift+Del)
4. Reinicie o frontend

---

## Reset Completo (Último Recurso)

Se nada funcionar, execute estes comandos na ordem:

```powershell
# 1. Parar tudo
docker-compose down -v

# 2. Remover containers LocalStack
docker ps -a --filter "name=localstack" -q | ForEach-Object { docker rm -f $_ }

# 3. Limpar volumes
docker volume prune -f

# 4. Limpar dados locais
Remove-Item -Recurse -Force .\localstack-data
Remove-Item -Recurse -Force .\backend\node_modules
Remove-Item -Recurse -Force .\backend\dist
Remove-Item -Recurse -Force .\frontend\node_modules
Remove-Item -Recurse -Force .\frontend\.next

# 5. Limpar Docker
docker system prune -af

# 6. Reinstalar dependências
cd backend
npm install
cd ..\frontend
npm install
cd ..

# 7. Iniciar LocalStack
docker-compose up -d
Start-Sleep -Seconds 30

# 8. Verificar
.\diagnose.ps1

# 9. Iniciar aplicação
# Terminal 1
cd backend
npm run start:dev

# Terminal 2
cd frontend
npm run dev
```

---

## Suporte Adicional

Se ainda tiver problemas:

1. Execute `.\diagnose.ps1` e copie a saída
2. Execute `docker-compose logs` e copie os erros
3. Execute `cd backend && npm run start:dev` e copie os erros
4. Consulte os arquivos de documentação:
   - [README.md](README.md)
   - [DEPENDENCIES.md](DEPENDENCIES.md)
   - [QUICKSTART.md](QUICKSTART.md)
