# ⚡ Guia de Início Rápido (5 minutos)

## Pré-requisitos (Instale antes)

- ✅ Node.js 18+ → https://nodejs.org/
- ✅ Docker Desktop → https://www.docker.com/products/docker-desktop/

## Passo a Passo Rápido

### 1️⃣ Iniciar LocalStack

```powershell
# Na raiz do projeto S3/
docker-compose up -d
```

**Aguarde 10 segundos** para o LocalStack inicializar.

Verificar:
```powershell
docker ps  # Deve mostrar container 'localstack' rodando
```

---

### 2️⃣ Configurar Backend

```powershell
cd backend
npm install
```

**Aguarde a instalação** (pode levar 2-3 minutos na primeira vez).

---

### 3️⃣ Iniciar Backend

```powershell
# Ainda dentro de backend/
npm run start:dev
```

**Você verá**:
```
🚀 Backend rodando na porta 3001
✅ Bucket my-app-bucket criado com sucesso
✅ Tabela users criada com sucesso
```

**Deixe este terminal aberto!**

---

### 4️⃣ Configurar Frontend (novo terminal)

```powershell
cd frontend
npm install
```

**Aguarde a instalação** (pode levar 2-3 minutos na primeira vez).

---

### 5️⃣ Iniciar Frontend

```powershell
# Ainda dentro de frontend/
npm run dev
```

**Você verá**:
```
▲ Next.js 14.0.0
- Local: http://localhost:3000
```

**Deixe este terminal aberto!**

---

### 6️⃣ Acessar o Sistema

Abra seu navegador em: **http://localhost:3000**

---

## Primeiro Uso

### 1. Criar Conta
1. Clique em "Cadastre-se"
2. Preencha:
   - Nome: `Seu Nome`
   - Email: `seu@email.com`
   - Senha: `123456` (mínimo 6 caracteres)
3. Clique em "Criar Conta"

**Você será redirecionado para o Dashboard automaticamente!**

### 2. Upload de Arquivo
1. No Dashboard, clique em "Selecionar Arquivo"
2. Escolha qualquer arquivo (imagem, PDF, etc.)
3. O arquivo será enviado automaticamente
4. Você verá a mensagem: "Arquivo enviado com sucesso!"

### 3. Download de Arquivo
1. Na lista de arquivos, clique em "Download"
2. O arquivo será baixado para seu computador

### 4. Excluir Arquivo
1. Clique em "Excluir"
2. Confirme a exclusão
3. O arquivo será removido

---

## Verificação Rápida

### ✅ LocalStack está funcionando?
```powershell
curl http://localhost:4566/_localstack/health
```

### ✅ Backend está funcionando?
```powershell
curl http://localhost:3001/auth/me
# Deve retornar: {"statusCode":401,"message":"Unauthorized"}
# (É normal, você não está autenticado)
```

### ✅ Frontend está funcionando?
Abra: http://localhost:3000

---

## Parar Tudo

```powershell
# Backend: Ctrl+C no terminal do backend
# Frontend: Ctrl+C no terminal do frontend
# LocalStack:
docker-compose down
```

---

## Recomeçar

```powershell
# 1. LocalStack
docker-compose up -d

# 2. Backend (novo terminal)
cd backend
npm run start:dev

# 3. Frontend (novo terminal)
cd frontend
npm run dev
```

---

## Problemas Comuns

### ❌ "Docker não está rodando"
**Solução**: Abra o Docker Desktop e aguarde inicializar.

### ❌ "Porta 3000 já em uso"
**Solução**: 
```powershell
# Matar processo na porta 3000
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

### ❌ "Porta 3001 já em uso"
**Solução**: 
```powershell
# Matar processo na porta 3001
netstat -ano | findstr :3001
taskkill /PID <PID> /F
```

### ❌ "Erro ao fazer login"
**Solução**: 
1. Limpe o cache do navegador (Ctrl+Shift+Del)
2. Ou abra em uma aba anônima
3. Crie uma nova conta

### ❌ "LocalStack não responde"
**Solução**: 
```powershell
docker-compose down
docker-compose up -d
# Aguarde 15 segundos
```

---

## Comandos Úteis

### Ver logs do LocalStack
```powershell
docker-compose logs -f
```

### Ver buckets S3
```powershell
aws --endpoint-url=http://localhost:4566 s3 ls
```

### Ver tabelas DynamoDB
```powershell
aws --endpoint-url=http://localhost:4566 dynamodb list-tables
```

### Limpar tudo e recomeçar
```powershell
# Parar tudo
docker-compose down

# Limpar dados
Remove-Item -Recurse -Force .\localstack-data

# Reiniciar
docker-compose up -d
cd backend; npm run start:dev
# (novo terminal)
cd frontend; npm run dev
```

---

## Próximos Passos

- 📖 Leia o [README.md](README.md) completo para entender o sistema
- 🏗️ Veja [ARCHITECTURE.md](ARCHITECTURE.md) para entender a arquitetura
- 📦 Consulte [DEPENDENCIES.md](DEPENDENCIES.md) para detalhes das dependências
- 💻 Use [COMMANDS.md](COMMANDS.md) como referência de comandos

---

## Resumo Visual

```
1. docker-compose up -d              → LocalStack rodando
                                       ↓
2. cd backend && npm install         → Dependências instaladas
                                       ↓
3. npm run start:dev                 → Backend rodando (3001)
                                       ↓
4. cd frontend && npm install        → Dependências instaladas
                                       ↓
5. npm run dev                       → Frontend rodando (3000)
                                       ↓
6. http://localhost:3000             → Sistema funcionando! 🎉
```

---

## Tempo Estimado

| Etapa | Tempo |
|-------|-------|
| Iniciar LocalStack | 10s |
| Instalar backend (primeira vez) | 2-3 min |
| Iniciar backend | 5s |
| Instalar frontend (primeira vez) | 2-3 min |
| Iniciar frontend | 10s |
| **TOTAL (primeira vez)** | **~6 minutos** |
| **TOTAL (próximas vezes)** | **~30 segundos** |

---

Pronto! Seu sistema está funcionando! 🚀

Qualquer dúvida, consulte os outros arquivos de documentação ou os comentários no código.
