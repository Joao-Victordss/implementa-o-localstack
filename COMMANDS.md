# Guia Rápido de Comandos

## Comandos Essenciais

### Iniciar Todo o Sistema (Automático)
```powershell
# Executar o script de setup (Windows)
.\setup.ps1

# OU manualmente:
# 1. Iniciar LocalStack
docker-compose up -d

# 2. Backend (em um terminal)
cd backend
npm install
npm run start:dev

# 3. Frontend (em outro terminal)
cd frontend
npm install
npm run dev
```

### Verificar LocalStack
```powershell
# Verificar status
.\check-localstack.ps1

# OU verificar manualmente
docker ps
curl http://localhost:4566/_localstack/health
```

### Parar Tudo
```powershell
# Parar LocalStack
docker-compose down

# Backend: Ctrl+C no terminal
# Frontend: Ctrl+C no terminal
```

## Comandos AWS CLI (Opcional)

### Configurar AWS CLI para LocalStack
```powershell
$env:AWS_ACCESS_KEY_ID = "test"
$env:AWS_SECRET_ACCESS_KEY = "test"
$env:AWS_DEFAULT_REGION = "us-east-1"
```

### S3 Commands
```powershell
# Listar buckets
aws --endpoint-url=http://localhost:4566 s3 ls

# Listar arquivos no bucket
aws --endpoint-url=http://localhost:4566 s3 ls s3://my-app-bucket --recursive

# Criar bucket manualmente (não necessário, o backend cria automaticamente)
aws --endpoint-url=http://localhost:4566 s3 mb s3://my-app-bucket

# Deletar bucket
aws --endpoint-url=http://localhost:4566 s3 rb s3://my-app-bucket --force
```

### DynamoDB Commands
```powershell
# Listar tabelas
aws --endpoint-url=http://localhost:4566 dynamodb list-tables

# Ver estrutura da tabela
aws --endpoint-url=http://localhost:4566 dynamodb describe-table --table-name users

# Ver todos os usuários
aws --endpoint-url=http://localhost:4566 dynamodb scan --table-name users

# Ver usuário específico
aws --endpoint-url=http://localhost:4566 dynamodb get-item --table-name users --key '{\"id\":{\"S\":\"USER_ID_AQUI\"}}'

# Deletar tabela
aws --endpoint-url=http://localhost:4566 dynamodb delete-table --table-name users
```

## Testar API com curl

### Registro
```powershell
curl -X POST http://localhost:3001/auth/register `
  -H "Content-Type: application/json" `
  -d '{\"name\":\"Teste\",\"email\":\"teste@exemplo.com\",\"password\":\"123456\"}'
```

### Login
```powershell
curl -X POST http://localhost:3001/auth/login `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"teste@exemplo.com\",\"password\":\"123456\"}'
```

### Upload (substitua TOKEN pelo token recebido no login)
```powershell
curl -X POST http://localhost:3001/files/upload `
  -H "Authorization: Bearer TOKEN_AQUI" `
  -F "file=@C:\caminho\para\arquivo.jpg"
```

### Listar arquivos
```powershell
curl -X GET http://localhost:3001/files/list `
  -H "Authorization: Bearer TOKEN_AQUI"
```

## Resetar Tudo

### Limpar dados do LocalStack
```powershell
# Parar LocalStack
docker-compose down

# Remover volume de dados (opcional)
Remove-Item -Recurse -Force .\localstack-data

# Reiniciar
docker-compose up -d
```

### Limpar node_modules
```powershell
# Backend
Remove-Item -Recurse -Force .\backend\node_modules
Remove-Item -Recurse -Force .\backend\dist

# Frontend
Remove-Item -Recurse -Force .\frontend\node_modules
Remove-Item -Recurse -Force .\frontend\.next

# Reinstalar
cd backend; npm install; cd ..
cd frontend; npm install; cd ..
```

## Troubleshooting

### LocalStack não inicia
```powershell
# Ver logs
docker-compose logs -f

# Reiniciar
docker-compose restart

# Rebuild
docker-compose down
docker-compose up -d --build
```

### Porta 4566 em uso
```powershell
# Verificar o que está usando a porta
netstat -ano | findstr :4566

# Matar processo (substitua PID)
taskkill /PID <PID> /F
```

### Backend não conecta ao LocalStack
1. Verifique se o LocalStack está rodando: `docker ps`
2. Teste o endpoint: `curl http://localhost:4566/_localstack/health`
3. Verifique as variáveis no `.env`
4. Reinicie o backend

### Frontend não conecta ao backend
1. Verifique se o backend está rodando na porta 3001
2. Verifique o arquivo `.env.local` do frontend
3. Limpe o cache do navegador
4. Reinicie o frontend

## Desenvolvimento

### Backend - Comandos úteis
```powershell
cd backend

# Modo desenvolvimento (hot reload)
npm run start:dev

# Modo produção
npm run build
npm run start:prod

# Lint
npm run lint

# Format
npm run format
```

### Frontend - Comandos úteis
```powershell
cd frontend

# Modo desenvolvimento
npm run dev

# Build para produção
npm run build

# Iniciar produção
npm run start

# Lint
npm run lint
```

## URLs Importantes

- Frontend: http://localhost:3000
- Backend: http://localhost:3001
- LocalStack: http://localhost:4566
- LocalStack Health: http://localhost:4566/_localstack/health

## Estrutura de Dados

### Usuário no DynamoDB
```json
{
  "id": "uuid-v4",
  "name": "Nome do Usuário",
  "email": "email@exemplo.com",
  "password": "hash-bcrypt",
  "createdAt": "2025-10-15T12:00:00.000Z"
}
```

### Arquivo no S3
- Chave: `{userId}/{timestamp}-{filename}`
- Metadata: originalName, userId
- Bucket: my-app-bucket

## Próximos Passos (Opcional)

1. Adicionar validação de tipo de arquivo
2. Adicionar limite de tamanho de arquivo
3. Adicionar paginação na lista de arquivos
4. Adicionar busca de arquivos
5. Adicionar compartilhamento de arquivos
6. Adicionar preview de imagens
7. Adicionar progresso de upload
8. Adicionar testes unitários
9. Adicionar Docker para backend e frontend
10. Deploy na AWS real
