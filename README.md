# Sistema de Upload/Download com S3 e Autenticação com DynamoDB

Sistema completo desenvolvido com **NestJS** (backend) e **Next.js** (frontend), integrado com **AWS S3** e **DynamoDB** usando **LocalStack** para desenvolvimento local.

## 📋 Funcionalidades

### Autenticação (DynamoDB)
- ✅ Registro de usuários
- ✅ Login com JWT
- ✅ Proteção de rotas
- ✅ Armazenamento de dados no DynamoDB (LocalStack)

### Upload/Download de Arquivos (S3)
- ✅ Upload de arquivos para S3 (LocalStack)
- ✅ Listagem de arquivos do usuário
- ✅ Download de arquivos
- ✅ Exclusão de arquivos
- ✅ Organização por usuário (cada usuário tem seus próprios arquivos)

## 🛠️ Tecnologias Utilizadas

### Backend
- **NestJS** - Framework Node.js
- **AWS SDK v3** - Cliente para S3 e DynamoDB
- **Passport & JWT** - Autenticação
- **Bcrypt** - Hash de senhas
- **Multer** - Upload de arquivos

### Frontend
- **Next.js 14** - Framework React
- **TypeScript** - Tipagem estática
- **Axios** - Cliente HTTP

### Infraestrutura
- **LocalStack** - Emulação local da AWS
- **Docker** - Containerização do LocalStack

## 📦 Dependências Necessárias

### Pré-requisitos
1. **Node.js** (versão 18 ou superior)
   - Download: https://nodejs.org/

2. **Docker Desktop** (para rodar o LocalStack)
   - Download: https://www.docker.com/products/docker-desktop/

3. **npm** ou **yarn** (geralmente vem com o Node.js)

## 🚀 Como Configurar e Executar

### Passo 1: Instalar o LocalStack

#### Opção 1: Usando Docker (Recomendado)

```powershell
# Na raiz do projeto, execute:
docker-compose up -d
```

Isso irá:
- Baixar a imagem do LocalStack
- Iniciar o container com S3 e DynamoDB
- Expor na porta 4566

Para verificar se está rodando:
```powershell
docker ps
```

Você deve ver o container `localstack` em execução.

#### Opção 2: Usando LocalStack CLI (Alternativa)

```powershell
# Instalar o LocalStack CLI
pip install localstack

# Iniciar o LocalStack
localstack start
```

### Passo 2: Configurar o Backend (NestJS)

```powershell
# Navegue até a pasta do backend
cd backend

# Instale as dependências
npm install

# As dependências incluem:
# - @nestjs/core, @nestjs/common - Core do NestJS
# - @aws-sdk/client-s3 - Cliente S3
# - @aws-sdk/client-dynamodb - Cliente DynamoDB
# - @aws-sdk/lib-dynamodb - Helper para DynamoDB
# - @nestjs/jwt, @nestjs/passport - Autenticação
# - passport-jwt, passport-local - Estratégias de autenticação
# - bcrypt - Hash de senhas
# - multer - Upload de arquivos
# - class-validator - Validação de dados

# Verifique o arquivo .env (já configurado)
# As variáveis de ambiente já estão no arquivo .env
```

**Variáveis de Ambiente (.env)**:
```env
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test
AWS_ENDPOINT=http://localhost:4566
S3_BUCKET_NAME=my-app-bucket
DYNAMODB_TABLE_NAME=users
JWT_SECRET=seu-segredo-super-secreto-aqui
JWT_EXPIRES_IN=24h
PORT=3001
```

**O que cada serviço faz**:
- **S3Service**: Gerencia upload, download, listagem e exclusão de arquivos no S3
- **DynamoDbService**: Gerencia operações CRUD no DynamoDB
- **AuthService**: Gerencia registro, login e autenticação de usuários

### Passo 3: Configurar o Frontend (Next.js)

```powershell
# Navegue até a pasta do frontend
cd ..\frontend

# Instale as dependências
npm install

# As dependências incluem:
# - next - Framework Next.js
# - react, react-dom - React
# - axios - Cliente HTTP
# - typescript - Tipagem estática
```

**Variáveis de Ambiente (.env.local)**:
```env
NEXT_PUBLIC_API_URL=http://localhost:3001
```

### Passo 4: Inicializar o DynamoDB e S3 (Automático)

O backend está configurado para **criar automaticamente**:
- ✅ Tabela `users` no DynamoDB (com índice de email)
- ✅ Bucket `my-app-bucket` no S3

Isso acontece quando você inicia o backend pela primeira vez!

### Passo 5: Executar o Sistema

#### Terminal 1 - LocalStack (se usando Docker Compose)
```powershell
# Na raiz do projeto
docker-compose up
```

#### Terminal 2 - Backend
```powershell
cd backend
npm run start:dev
```

O backend estará rodando em: `http://localhost:3001`

#### Terminal 3 - Frontend
```powershell
cd frontend
npm run dev
```

O frontend estará rodando em: `http://localhost:3000`

## 🎯 Como Usar o Sistema

### 1. Acesse o Frontend
Abra seu navegador em: `http://localhost:3000`

### 2. Criar uma Conta
- Clique em "Cadastre-se"
- Preencha: Nome, Email e Senha (mínimo 6 caracteres)
- Clique em "Criar Conta"

**O que acontece nos bastidores**:
- Senha é criptografada com bcrypt
- Dados são salvos no DynamoDB (LocalStack)
- Um token JWT é gerado
- Você é automaticamente autenticado

### 3. Fazer Login
- Insira seu Email e Senha
- Clique em "Entrar"

**O que acontece nos bastidores**:
- Sistema busca usuário no DynamoDB
- Verifica a senha com bcrypt
- Gera um novo token JWT
- Token é armazenado no localStorage

### 4. Upload de Arquivos
- No Dashboard, clique em "Selecionar Arquivo"
- Escolha um arquivo (imagem, PDF, etc.)
- O arquivo será enviado automaticamente

**O que acontece nos bastidores**:
- Arquivo é enviado via multipart/form-data
- Backend salva no S3 com o padrão: `{userId}/{timestamp}-{filename}`
- Arquivo fica isolado por usuário

### 5. Download de Arquivos
- Clique em "Download" no arquivo desejado
- O arquivo será baixado para seu computador

### 6. Excluir Arquivos
- Clique em "Excluir" no arquivo desejado
- Confirme a exclusão
- O arquivo será removido do S3

## 🔍 Verificar Dados no LocalStack

### Verificar Tabela DynamoDB

```powershell
# Listar tabelas
aws --endpoint-url=http://localhost:4566 dynamodb list-tables

# Ver todos os usuários
aws --endpoint-url=http://localhost:4566 dynamodb scan --table-name users
```

### Verificar Bucket S3

```powershell
# Listar buckets
aws --endpoint-url=http://localhost:4566 s3 ls

# Listar arquivos no bucket
aws --endpoint-url=http://localhost:4566 s3 ls s3://my-app-bucket --recursive
```

**Nota**: Se você não tem o AWS CLI instalado, pode instalar com:
```powershell
# Usando MSI Installer
# Download: https://awscli.amazonaws.com/AWSCLIV2.msi
```

## 📁 Estrutura do Projeto

```
S3/
├── backend/                   # NestJS Backend
│   ├── src/
│   │   ├── auth/             # Módulo de Autenticação
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   ├── auth.module.ts
│   │   │   ├── dto/          # DTOs de validação
│   │   │   ├── guards/       # Guards JWT
│   │   │   └── strategies/   # Estratégia JWT
│   │   ├── aws/              # Módulo AWS (S3 e DynamoDB)
│   │   │   ├── s3.service.ts
│   │   │   ├── dynamodb.service.ts
│   │   │   └── aws.module.ts
│   │   ├── files/            # Módulo de Arquivos
│   │   │   ├── files.controller.ts
│   │   │   ├── files.service.ts
│   │   │   └── files.module.ts
│   │   ├── app.module.ts
│   │   └── main.ts
│   ├── package.json
│   └── .env
│
├── frontend/                  # Next.js Frontend
│   ├── src/
│   │   ├── pages/            # Páginas
│   │   │   ├── index.tsx     # Página inicial
│   │   │   ├── login.tsx     # Login
│   │   │   ├── register.tsx  # Registro
│   │   │   └── dashboard.tsx # Dashboard
│   │   ├── services/         # Serviços API
│   │   │   └── api.ts
│   │   └── styles/           # Estilos CSS
│   ├── package.json
│   └── .env.local
│
├── docker-compose.yml         # Configuração do LocalStack
└── README.md                  # Esta documentação
```

## 🔧 Endpoints da API

### Autenticação
- `POST /auth/register` - Criar conta
- `POST /auth/login` - Fazer login
- `GET /auth/me` - Obter perfil (autenticado)

### Arquivos (Todos requerem autenticação)
- `POST /files/upload` - Upload de arquivo
- `GET /files/list` - Listar arquivos do usuário
- `GET /files/download/:key` - Download de arquivo
- `DELETE /files/:key` - Excluir arquivo

## 🐛 Troubleshooting

### LocalStack não está rodando
```powershell
# Verificar se o Docker está rodando
docker ps

# Reiniciar o LocalStack
docker-compose down
docker-compose up -d
```

### Erro de conexão com LocalStack
- Verifique se o LocalStack está em `http://localhost:4566`
- Confirme que as portas não estão sendo usadas por outros serviços

### Tabela ou Bucket não foram criados
- Reinicie o backend (ele cria automaticamente ao iniciar)
- Ou crie manualmente (veja scripts acima)

### Erro de autenticação
- Limpe o localStorage do navegador
- Faça login novamente

## 📚 Recursos Adicionais

- [Documentação do LocalStack](https://docs.localstack.cloud/)
- [AWS SDK for JavaScript v3](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/)
- [NestJS Documentation](https://docs.nestjs.com/)
- [Next.js Documentation](https://nextjs.org/docs)

## ✅ Checklist de Configuração

- [ ] Docker Desktop instalado e rodando
- [ ] Node.js 18+ instalado
- [ ] LocalStack iniciado (porta 4566 acessível)
- [ ] Backend: `npm install` executado
- [ ] Frontend: `npm install` executado
- [ ] Arquivo `.env` configurado no backend
- [ ] Arquivo `.env.local` configurado no frontend
- [ ] Backend rodando em `http://localhost:3001`
- [ ] Frontend rodando em `http://localhost:3000`
- [ ] Conta criada e login funcionando
- [ ] Upload/Download de arquivos testado

## 🎉 Pronto!

Seu sistema está completo e funcionando com:
- ✅ Autenticação de usuários com DynamoDB
- ✅ Upload/Download de arquivos com S3
- ✅ Tudo rodando localmente com LocalStack

Bom uso! 🚀
