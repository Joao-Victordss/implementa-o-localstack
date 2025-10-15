# 📦 Guia Completo de Dependências

## Índice
1. [Pré-requisitos](#pré-requisitos)
2. [Dependências do Backend](#dependências-do-backend)
3. [Dependências do Frontend](#dependências-do-frontend)
4. [Configuração do DynamoDB](#configuração-do-dynamodb)
5. [Configuração do S3](#configuração-do-s3)

---

## Pré-requisitos

### 1. Node.js (v18 ou superior)
**O que é**: Runtime JavaScript para executar código fora do navegador.

**Como instalar**:
- **Windows**: 
  1. Acesse: https://nodejs.org/
  2. Baixe a versão LTS (recomendada)
  3. Execute o instalador `.msi`
  4. Siga o assistente de instalação
  
**Verificar instalação**:
```powershell
node --version  # Deve mostrar v18.x.x ou superior
npm --version   # Deve mostrar 9.x.x ou superior
```

### 2. Docker Desktop
**O que é**: Plataforma para executar containers (incluindo o LocalStack).

**Como instalar**:
- **Windows**:
  1. Acesse: https://www.docker.com/products/docker-desktop/
  2. Baixe o Docker Desktop para Windows
  3. Execute o instalador
  4. Reinicie o computador se solicitado
  5. Abra o Docker Desktop

**Verificar instalação**:
```powershell
docker --version         # Deve mostrar versão
docker-compose --version # Deve mostrar versão
docker ps                # Deve listar containers (vazio no início)
```

### 3. AWS CLI (Opcional - apenas para testes manuais)
**O que é**: Interface de linha de comando para interagir com AWS/LocalStack.

**Como instalar**:
- **Windows**:
  1. Baixe: https://awscli.amazonaws.com/AWSCLIV2.msi
  2. Execute o instalador
  3. Reinicie o terminal

**Verificar instalação**:
```powershell
aws --version  # Deve mostrar versão
```

---

## Dependências do Backend

### Instalação
```powershell
cd backend
npm install
```

### Dependências Principais

#### 1. **NestJS Core** (Framework Backend)
```json
"@nestjs/common": "^10.0.0"
"@nestjs/core": "^10.0.0"
"@nestjs/platform-express": "^10.0.0"
```
**O que faz**: Framework Node.js para construir aplicações server-side escaláveis.

#### 2. **AWS SDK v3** (Integração com AWS/LocalStack)
```json
"@aws-sdk/client-s3": "^3.400.0"
"@aws-sdk/client-dynamodb": "^3.400.0"
"@aws-sdk/lib-dynamodb": "^3.400.0"
"@aws-sdk/s3-request-presigner": "^3.400.0"
```
**O que faz**:
- `client-s3`: Operações com S3 (upload, download, listagem)
- `client-dynamodb`: Operações low-level com DynamoDB
- `lib-dynamodb`: Helpers para DynamoDB (operações mais simples)
- `s3-request-presigner`: Gerar URLs assinadas para download

#### 3. **Autenticação** (JWT e Passport)
```json
"@nestjs/jwt": "^10.1.0"
"@nestjs/passport": "^10.0.0"
"passport": "^0.6.0"
"passport-jwt": "^4.0.1"
"passport-local": "^1.0.0"
```
**O que faz**:
- `@nestjs/jwt`: Geração e validação de tokens JWT
- `passport`: Framework de autenticação
- `passport-jwt`: Estratégia JWT para Passport
- `passport-local`: Estratégia local (email/senha)

#### 4. **Segurança** (Criptografia de Senhas)
```json
"bcrypt": "^5.1.0"
```
**O que faz**: Hash e validação de senhas de forma segura.

#### 5. **Validação** (DTOs)
```json
"class-validator": "^0.14.0"
"class-transformer": "^0.5.1"
```
**O que faz**: Validação automática de dados de entrada (DTOs).

#### 6. **Upload de Arquivos**
```json
"multer": "^1.4.5-lts.1"
```
**O que faz**: Middleware para upload de arquivos multipart/form-data.

#### 7. **Utilidades**
```json
"uuid": "^9.0.0"
"reflect-metadata": "^0.1.13"
"rxjs": "^7.8.1"
```
**O que faz**:
- `uuid`: Geração de IDs únicos para usuários
- `reflect-metadata`: Decorators do TypeScript
- `rxjs`: Programação reativa (usado pelo NestJS)

### Dependências de Desenvolvimento
```json
"@nestjs/cli": "^10.0.0"
"@nestjs/schematics": "^10.0.0"
"@types/express": "^4.17.17"
"@types/node": "^20.3.1"
"@types/passport-jwt": "^3.0.9"
"@types/passport-local": "^1.0.35"
"@types/bcrypt": "^5.0.0"
"@types/multer": "^1.4.7"
"@types/uuid": "^9.0.2"
"typescript": "^5.1.3"
```
**O que faz**: Tipagens TypeScript e ferramentas de desenvolvimento.

---

## Dependências do Frontend

### Instalação
```powershell
cd frontend
npm install
```

### Dependências Principais

#### 1. **Next.js e React** (Framework Frontend)
```json
"next": "14.0.0"
"react": "^18"
"react-dom": "^18"
```
**O que faz**:
- `next`: Framework React com SSR e routing
- `react`: Biblioteca para interfaces de usuário
- `react-dom`: Renderização do React no DOM

#### 2. **HTTP Client**
```json
"axios": "^1.5.0"
```
**O que faz**: Cliente HTTP para fazer requisições ao backend.

### Dependências de Desenvolvimento
```json
"typescript": "^5"
"@types/node": "^20"
"@types/react": "^18"
"@types/react-dom": "^18"
"eslint": "^8"
"eslint-config-next": "14.0.0"
```
**O que faz**: Tipagens TypeScript e linting.

---

## Configuração do DynamoDB

### O que é DynamoDB?
Banco de dados NoSQL gerenciado pela AWS. Neste projeto, usamos o LocalStack para emular localmente.

### Estrutura da Tabela `users`

#### Schema
```javascript
{
  TableName: 'users',
  KeySchema: [
    { AttributeName: 'id', KeyType: 'HASH' }  // Partition Key
  ],
  AttributeDefinitions: [
    { AttributeName: 'id', AttributeType: 'S' },      // String
    { AttributeName: 'email', AttributeType: 'S' }    // String
  ],
  GlobalSecondaryIndexes: [
    {
      IndexName: 'EmailIndex',
      KeySchema: [
        { AttributeName: 'email', KeyType: 'HASH' }
      ],
      Projection: { ProjectionType: 'ALL' },
      ProvisionedThroughput: {
        ReadCapacityUnits: 5,
        WriteCapacityUnits: 5
      }
    }
  ]
}
```

#### Explicação

**Partition Key (id)**:
- Chave primária da tabela
- UUID v4 gerado automaticamente
- Usado para buscar usuário por ID

**Global Secondary Index (EmailIndex)**:
- Permite buscar usuário por email
- Necessário para login (busca por email)
- `ProjectionType: 'ALL'` significa que todos os atributos são projetados

**Atributos armazenados**:
```javascript
{
  id: 'uuid-v4',                    // Gerado automaticamente
  name: 'Nome do Usuário',          // Informado no registro
  email: 'usuario@exemplo.com',     // Informado no registro (único)
  password: 'hash-bcrypt',          // Hash da senha (bcrypt)
  createdAt: '2025-10-15T12:00:00Z' // Timestamp de criação
}
```

### Como a tabela é criada?

**Automático** - O serviço `DynamoDbService` cria automaticamente ao iniciar:

```typescript
// backend/src/aws/dynamodb.service.ts
async onModuleInit() {
  await this.createTableIfNotExists();
}
```

**Fluxo**:
1. Backend inicia
2. `DynamoDbService` executa `onModuleInit()`
3. Tenta descrever a tabela `users`
4. Se não existir (erro `ResourceNotFoundException`):
   - Cria a tabela com o schema definido
   - Aguarda 2 segundos para a tabela ficar ativa
5. Se já existir, apenas loga a confirmação

### Operações no DynamoDB

#### 1. **PutItem** (Criar usuário)
```typescript
await dynamoDbService.putItem({
  id: 'uuid',
  name: 'Nome',
  email: 'email@exemplo.com',
  password: 'hash',
  createdAt: new Date().toISOString()
});
```

#### 2. **GetItem** (Buscar por ID)
```typescript
const user = await dynamoDbService.getItem('user-id');
```

#### 3. **Query** (Buscar por email usando GSI)
```typescript
const user = await dynamoDbService.findByEmail('email@exemplo.com');
```

#### 4. **Scan** (Listar todos - não usado no projeto)
```typescript
const users = await dynamoDbService.scanItems();
```

### Verificar Tabela Manualmente

```powershell
# Listar tabelas
aws --endpoint-url=http://localhost:4566 dynamodb list-tables

# Descrever estrutura da tabela
aws --endpoint-url=http://localhost:4566 dynamodb describe-table --table-name users

# Ver todos os usuários
aws --endpoint-url=http://localhost:4566 dynamodb scan --table-name users

# Ver usuário específico
aws --endpoint-url=http://localhost:4566 dynamodb get-item `
  --table-name users `
  --key '{\"id\":{\"S\":\"USER_ID_AQUI\"}}'

# Buscar por email (usando GSI)
aws --endpoint-url=http://localhost:4566 dynamodb query `
  --table-name users `
  --index-name EmailIndex `
  --key-condition-expression "email = :email" `
  --expression-attribute-values '{\":email\":{\"S\":\"teste@exemplo.com\"}}'
```

---

## Configuração do S3

### O que é S3?
Simple Storage Service - Armazenamento de objetos da AWS. Usado para armazenar arquivos (imagens, documentos, etc.).

### Estrutura do Bucket

**Nome do Bucket**: `my-app-bucket`

**Estrutura de pastas**:
```
my-app-bucket/
├── {userId1}/
│   ├── 1697384400000-foto.jpg
│   ├── 1697384500000-documento.pdf
│   └── 1697384600000-video.mp4
├── {userId2}/
│   ├── 1697384700000-imagem.png
│   └── 1697384800000-arquivo.txt
└── {userId3}/
    └── 1697384900000-outro.jpg
```

**Padrão da chave (key)**:
```
{userId}/{timestamp}-{originalFilename}
```

Exemplo:
```
550e8400-e29b-41d4-a716-446655440000/1697384400000-minha-foto.jpg
```

### Como o bucket é criado?

**Automático** - O serviço `S3Service` cria automaticamente ao iniciar:

```typescript
// backend/src/aws/s3.service.ts
async onModuleInit() {
  await this.createBucketIfNotExists();
}
```

**Fluxo**:
1. Backend inicia
2. `S3Service` executa `onModuleInit()`
3. Tenta verificar se o bucket existe (`HeadBucket`)
4. Se não existir (erro `NotFound`):
   - Cria o bucket com `CreateBucket`
5. Se já existir, apenas loga a confirmação

### Operações no S3

#### 1. **PutObject** (Upload)
```typescript
await s3Service.uploadFile(file, userId);
// Cria objeto com key: {userId}/{timestamp}-{filename}
```

**Metadata armazenada**:
```javascript
{
  originalName: 'foto.jpg',
  userId: 'user-id'
}
```

#### 2. **GetObject** (Download)
```typescript
const fileBuffer = await s3Service.getFile(key);
```

#### 3. **ListObjectsV2** (Listar arquivos do usuário)
```typescript
const files = await s3Service.listUserFiles(userId);
// Retorna apenas objetos com prefix: {userId}/
```

#### 4. **DeleteObject** (Excluir)
```typescript
await s3Service.deleteFile(key);
```

#### 5. **GetSignedUrl** (URL temporária)
```typescript
const url = await s3Service.getSignedDownloadUrl(key);
// URL válida por 1 hora
```

### Verificar Bucket Manualmente

```powershell
# Listar buckets
aws --endpoint-url=http://localhost:4566 s3 ls

# Listar arquivos no bucket
aws --endpoint-url=http://localhost:4566 s3 ls s3://my-app-bucket --recursive

# Fazer upload manual
aws --endpoint-url=http://localhost:4566 s3 cp arquivo.txt s3://my-app-bucket/

# Fazer download manual
aws --endpoint-url=http://localhost:4566 s3 cp s3://my-app-bucket/arquivo.txt ./

# Ver metadados de um objeto
aws --endpoint-url=http://localhost:4566 s3api head-object `
  --bucket my-app-bucket `
  --key "user-id/timestamp-file.jpg"
```

### Configuração do LocalStack para S3

No arquivo `.env`:
```env
AWS_ENDPOINT=http://localhost:4566
S3_BUCKET_NAME=my-app-bucket
```

No código (`s3.service.ts`):
```typescript
new S3Client({
  region: 'us-east-1',
  endpoint: 'http://localhost:4566',
  credentials: {
    accessKeyId: 'test',
    secretAccessKey: 'test',
  },
  forcePathStyle: true,  // IMPORTANTE para LocalStack
});
```

**`forcePathStyle: true`** é essencial para o LocalStack funcionar corretamente com S3.

---

## Resumo dos Serviços

### Backend (`NestJS`)

| Serviço | Responsabilidade |
|---------|------------------|
| **AuthService** | Registro, login, geração de JWT |
| **DynamoDbService** | Operações CRUD no DynamoDB |
| **S3Service** | Upload, download, listagem de arquivos |
| **FilesService** | Lógica de negócio para arquivos |

### Frontend (`Next.js`)

| Componente | Responsabilidade |
|------------|------------------|
| **authService** | Chamadas de autenticação (registro/login) |
| **filesService** | Chamadas de arquivos (upload/download) |
| **localStorage** | Armazenamento do token JWT |

---

## Fluxo Completo de Autenticação

1. **Registro**:
   ```
   Frontend → POST /auth/register → Backend
   → AuthService.register()
   → bcrypt.hash(password)
   → DynamoDbService.putItem()
   → DynamoDB (LocalStack)
   → Gera JWT
   → Retorna { user, token }
   ```

2. **Login**:
   ```
   Frontend → POST /auth/login → Backend
   → AuthService.login()
   → DynamoDbService.findByEmail()
   → DynamoDB Query (EmailIndex)
   → bcrypt.compare(password)
   → Gera JWT
   → Retorna { user, token }
   ```

3. **Requisições Autenticadas**:
   ```
   Frontend → Header: Authorization: Bearer {token}
   → JwtAuthGuard
   → JwtStrategy.validate()
   → Extrai userId do token
   → Anexa ao request.user
   → Executa controller
   ```

---

## Fluxo Completo de Upload/Download

1. **Upload**:
   ```
   Frontend → FormData com file
   → POST /files/upload
   → JwtAuthGuard (valida token)
   → FilesController.uploadFile()
   → FilesService.uploadFile()
   → S3Service.uploadFile()
   → PutObjectCommand
   → S3 (LocalStack)
   → Retorna { key, metadata }
   ```

2. **Listagem**:
   ```
   Frontend → GET /files/list
   → JwtAuthGuard
   → FilesController.listFiles()
   → FilesService.listUserFiles()
   → S3Service.listUserFiles()
   → ListObjectsV2Command (prefix: userId/)
   → Retorna array de arquivos
   ```

3. **Download**:
   ```
   Frontend → GET /files/download/{key}
   → JwtAuthGuard
   → Verifica se key pertence ao userId
   → FilesService.downloadFile()
   → S3Service.getFile()
   → GetObjectCommand
   → Stream do arquivo
   → res.send(fileBuffer)
   ```

---

## Segurança Implementada

### 1. **Autenticação JWT**
- Token gerado com secret do `.env`
- Expira em 24 horas
- Armazenado no localStorage do navegador

### 2. **Hash de Senhas**
- Bcrypt com salt rounds = 10
- Nunca armazena senha em texto plano

### 3. **Isolamento de Arquivos**
- Cada usuário só acessa seus próprios arquivos
- Verificação de `key.startsWith(userId/)`
- Retorna 403 Forbidden se tentar acessar arquivo de outro usuário

### 4. **Validação de Dados**
- DTOs com class-validator
- Email válido obrigatório
- Senha mínima de 6 caracteres
- Nome obrigatório

### 5. **CORS**
- Habilitado apenas para `http://localhost:3000`
- Credentials permitido

---

## Próximos Passos para Produção

1. **Migrar para AWS Real**:
   - Alterar `AWS_ENDPOINT` para endpoints reais
   - Configurar IAM roles e políticas
   - Usar AWS Secrets Manager para credenciais

2. **Melhorar Segurança**:
   - HTTPS obrigatório
   - Rate limiting
   - Refresh tokens
   - 2FA (autenticação de dois fatores)

3. **Melhorar Performance**:
   - Paginação na listagem de arquivos
   - Cache com Redis
   - CDN para arquivos estáticos

4. **Adicionar Funcionalidades**:
   - Preview de imagens
   - Progresso de upload
   - Compartilhamento de arquivos
   - Pastas/organizção

---

Pronto! Agora você tem todas as informações sobre dependências e configuração. 🚀
