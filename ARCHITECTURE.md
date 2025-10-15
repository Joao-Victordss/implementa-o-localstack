# 🏗️ Arquitetura do Sistema

## Visão Geral

```
┌─────────────────────────────────────────────────────────────┐
│                        NAVEGADOR                             │
│                     (localhost:3000)                         │
│                                                              │
│  ┌──────────┐  ┌───────────┐  ┌──────────────┐            │
│  │  Login   │  │  Registro │  │  Dashboard   │            │
│  │  Page    │  │   Page    │  │     Page     │            │
│  └────┬─────┘  └─────┬─────┘  └──────┬───────┘            │
│       │              │                │                     │
│       └──────────────┴────────────────┘                     │
│                      │                                      │
│              ┌───────▼────────┐                            │
│              │  API Service   │                            │
│              │  (axios)       │                            │
│              └───────┬────────┘                            │
└──────────────────────┼─────────────────────────────────────┘
                       │ HTTP/JSON
                       │ Authorization: Bearer {JWT}
                       │
┌──────────────────────▼─────────────────────────────────────┐
│                   BACKEND (NestJS)                          │
│                  (localhost:3001)                           │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │              Auth Module                             │  │
│  │  ┌────────────┐  ┌──────────┐  ┌───────────┐       │  │
│  │  │   Auth     │  │   JWT    │  │  Passport │       │  │
│  │  │ Controller │  │ Strategy │  │  Guards   │       │  │
│  │  └─────┬──────┘  └────┬─────┘  └─────┬─────┘       │  │
│  │        │              │              │              │  │
│  │        └──────────────┴──────────────┘              │  │
│  │                      │                               │  │
│  │               ┌──────▼───────┐                       │  │
│  │               │ Auth Service │                       │  │
│  │               └──────┬───────┘                       │  │
│  └──────────────────────┼───────────────────────────────┘  │
│                         │                                   │
│  ┌─────────────────────┼───────────────────────────────┐  │
│  │              Files Module                            │  │
│  │  ┌──────────────┐   │                               │  │
│  │  │    Files     │   │                               │  │
│  │  │  Controller  │   │                               │  │
│  │  └──────┬───────┘   │                               │  │
│  │         │           │                               │  │
│  │  ┌──────▼───────┐   │                               │  │
│  │  │ Files Service│   │                               │  │
│  │  └──────┬───────┘   │                               │  │
│  └─────────┼───────────┼───────────────────────────────┘  │
│            │           │                                   │
│  ┌─────────▼───────────▼───────────────────────────────┐  │
│  │                AWS Module (Global)                   │  │
│  │  ┌──────────────┐         ┌──────────────┐          │  │
│  │  │  S3 Service  │         │  DynamoDB    │          │  │
│  │  │              │         │   Service    │          │  │
│  │  └──────┬───────┘         └──────┬───────┘          │  │
│  └─────────┼────────────────────────┼──────────────────┘  │
└────────────┼────────────────────────┼─────────────────────┘
             │                        │
             │ AWS SDK v3             │ AWS SDK v3
             │                        │
┌────────────▼────────────────────────▼─────────────────────┐
│                   LOCALSTACK (Docker)                      │
│                    (localhost:4566)                        │
│                                                            │
│  ┌──────────────────┐         ┌──────────────────┐       │
│  │        S3        │         │     DynamoDB     │       │
│  │                  │         │                  │       │
│  │  my-app-bucket/  │         │  Tabela: users   │       │
│  │  ├─ userId1/     │         │  ├─ id (PK)      │       │
│  │  │  ├─ file1.jpg │         │  ├─ email (GSI)  │       │
│  │  │  └─ file2.pdf │         │  ├─ name         │       │
│  │  └─ userId2/     │         │  ├─ password     │       │
│  │     └─ file3.png │         │  └─ createdAt    │       │
│  └──────────────────┘         └──────────────────┘       │
└────────────────────────────────────────────────────────────┘
```

---

## Fluxo de Registro

```
┌─────────┐                                                ┌──────────┐
│ Browser │                                                │ Backend  │
└────┬────┘                                                └────┬─────┘
     │                                                          │
     │ 1. Usuário preenche formulário                          │
     │    (nome, email, senha)                                 │
     │                                                          │
     │ 2. POST /auth/register                                  │
     │    {name, email, password}                              │
     ├─────────────────────────────────────────────────────────>│
     │                                                          │
     │                                         3. AuthService  │
     │                                            .register()   │
     │                                                 │        │
     │                                         4. Verifica se   │
     │                                            email existe  │
     │                                                 │        │
     │                                         ┌───────▼──────┐ │
     │                                         │  DynamoDB    │ │
     │                                         │  findByEmail │ │
     │                                         └───────┬──────┘ │
     │                                                 │        │
     │                                         5. Hash senha    │
     │                                            bcrypt.hash() │
     │                                                 │        │
     │                                         6. Cria usuário  │
     │                                                 │        │
     │                                         ┌───────▼──────┐ │
     │                                         │  DynamoDB    │ │
     │                                         │   putItem    │ │
     │                                         └───────┬──────┘ │
     │                                                 │        │
     │                                         7. Gera JWT      │
     │                                            token         │
     │                                                 │        │
     │ 8. Retorna {user, token}                       │        │
     │<─────────────────────────────────────────────────────────┤
     │                                                          │
     │ 9. Armazena token e user                                │
     │    no localStorage                                       │
     │                                                          │
     │ 10. Redireciona para /dashboard                         │
     │                                                          │
```

---

## Fluxo de Login

```
┌─────────┐                                                ┌──────────┐
│ Browser │                                                │ Backend  │
└────┬────┘                                                └────┬─────┘
     │                                                          │
     │ 1. Usuário preenche formulário                          │
     │    (email, senha)                                       │
     │                                                          │
     │ 2. POST /auth/login                                     │
     │    {email, password}                                    │
     ├─────────────────────────────────────────────────────────>│
     │                                                          │
     │                                         3. AuthService  │
     │                                            .login()      │
     │                                                 │        │
     │                                         4. Busca usuário │
     │                                                 │        │
     │                                         ┌───────▼──────┐ │
     │                                         │  DynamoDB    │ │
     │                                         │  findByEmail │ │
     │                                         └───────┬──────┘ │
     │                                                 │        │
     │                                         5. Verifica senha│
     │                                            bcrypt.compare│
     │                                                 │        │
     │                                         6. Gera JWT      │
     │                                            token         │
     │                                                 │        │
     │ 7. Retorna {user, token}                       │        │
     │<─────────────────────────────────────────────────────────┤
     │                                                          │
     │ 8. Armazena token e user                                │
     │    no localStorage                                       │
     │                                                          │
     │ 9. Redireciona para /dashboard                          │
     │                                                          │
```

---

## Fluxo de Upload

```
┌─────────┐                                     ┌──────────┐        ┌────────┐
│ Browser │                                     │ Backend  │        │   S3   │
└────┬────┘                                     └────┬─────┘        └───┬────┘
     │                                               │                  │
     │ 1. Usuário seleciona arquivo                 │                  │
     │                                               │                  │
     │ 2. POST /files/upload                        │                  │
     │    Authorization: Bearer {JWT}               │                  │
     │    Content-Type: multipart/form-data         │                  │
     │    Body: FormData com file                   │                  │
     ├──────────────────────────────────────────────>│                  │
     │                                               │                  │
     │                                  3. JwtGuard verifica token     │
     │                                     Extrai userId do JWT        │
     │                                               │                  │
     │                                  4. FilesService.uploadFile()   │
     │                                               │                  │
     │                                  5. S3Service.uploadFile()      │
     │                                               │                  │
     │                                  6. Gera key:                   │
     │                                     {userId}/{timestamp}-{name} │
     │                                               │                  │
     │                                  7. PutObjectCommand            │
     │                                               ├─────────────────>│
     │                                               │                  │
     │                                               │  8. Armazena    │
     │                                               │     arquivo      │
     │                                               │                  │
     │                                               │<─────────────────┤
     │                                               │                  │
     │ 9. Retorna {message, key, metadata}          │                  │
     │<──────────────────────────────────────────────┤                  │
     │                                               │                  │
     │ 10. Atualiza lista de arquivos               │                  │
     │                                               │                  │
```

---

## Fluxo de Download

```
┌─────────┐                                     ┌──────────┐        ┌────────┐
│ Browser │                                     │ Backend  │        │   S3   │
└────┬────┘                                     └────┬─────┘        └───┬────┘
     │                                               │                  │
     │ 1. Usuário clica em "Download"               │                  │
     │                                               │                  │
     │ 2. GET /files/download/{key}                 │                  │
     │    Authorization: Bearer {JWT}               │                  │
     ├──────────────────────────────────────────────>│                  │
     │                                               │                  │
     │                                  3. JwtGuard verifica token     │
     │                                     Extrai userId                │
     │                                               │                  │
     │                                  4. Verifica se key pertence    │
     │                                     ao userId (segurança)        │
     │                                               │                  │
     │                                  5. S3Service.getFile(key)      │
     │                                               │                  │
     │                                  6. GetObjectCommand            │
     │                                               ├─────────────────>│
     │                                               │                  │
     │                                               │  7. Retorna     │
     │                                               │     stream       │
     │                                               │<─────────────────┤
     │                                               │                  │
     │                                  8. Converte stream para Buffer │
     │                                               │                  │
     │ 9. Response com arquivo (blob)               │                  │
     │    Content-Type: application/octet-stream    │                  │
     │    Content-Disposition: attachment           │                  │
     │<──────────────────────────────────────────────┤                  │
     │                                               │                  │
     │ 10. Navegador baixa arquivo                  │                  │
     │                                               │                  │
```

---

## Estrutura de Dados

### DynamoDB - Tabela `users`

```
┌─────────────────────────────────────────────────────────┐
│                     Tabela: users                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Partition Key: id (String - UUID v4)                   │
│                                                         │
│  Global Secondary Index: EmailIndex                     │
│  └─ Key: email (String)                                 │
│                                                         │
│  Atributos:                                             │
│  ┌───────────┬──────────────────┬───────────────────┐  │
│  │  Campo    │      Tipo        │   Exemplo         │  │
│  ├───────────┼──────────────────┼───────────────────┤  │
│  │ id        │ String (UUID)    │ 550e8400-e29b...  │  │
│  │ name      │ String           │ João Silva        │  │
│  │ email     │ String (unique)  │ joao@exemplo.com  │  │
│  │ password  │ String (hash)    │ $2b$10$...       │  │
│  │ createdAt │ String (ISO)     │ 2025-10-15T12:... │  │
│  └───────────┴──────────────────┴───────────────────┘  │
│                                                         │
│  Índices:                                               │
│  1. Primary Key (id) - para busca rápida por ID         │
│  2. EmailIndex (email) - para login (busca por email)   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### S3 - Bucket `my-app-bucket`

```
┌─────────────────────────────────────────────────────────┐
│                Bucket: my-app-bucket                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Estrutura:                                             │
│                                                         │
│  my-app-bucket/                                         │
│  ├─ 550e8400-e29b-41d4.../         (userId 1)           │
│  │  ├─ 1697384400000-foto.jpg                          │
│  │  │  ├─ Body: [binary data]                          │
│  │  │  ├─ ContentType: image/jpeg                      │
│  │  │  └─ Metadata:                                     │
│  │  │     ├─ originalName: foto.jpg                     │
│  │  │     └─ userId: 550e8400...                        │
│  │  ├─ 1697384500000-documento.pdf                     │
│  │  └─ 1697384600000-video.mp4                         │
│  │                                                      │
│  ├─ 661f9511-f3ac-52e5.../         (userId 2)           │
│  │  └─ 1697384700000-imagem.png                        │
│  │                                                      │
│  └─ 772g0622-g4bd-63f6.../         (userId 3)           │
│     └─ 1697384800000-arquivo.txt                       │
│                                                         │
│  Padrão da Key:                                         │
│  {userId}/{timestamp}-{originalFilename}                │
│                                                         │
│  Exemplo:                                               │
│  550e8400-e29b-41d4-a716-446655440000/                  │
│    1697384400000-minha-foto.jpg                         │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Camadas de Segurança

```
┌─────────────────────────────────────────────────────────┐
│                   SEGURANÇA EM CAMADAS                  │
└─────────────────────────────────────────────────────────┘

1. AUTENTICAÇÃO (Quem é você?)
   ┌────────────────────────────────────────────────┐
   │ • JWT Token                                    │
   │ • Secret do .env                               │
   │ • Expiração em 24h                             │
   │ • Armazenado no localStorage                   │
   └────────────────────────────────────────────────┘

2. AUTORIZAÇÃO (O que você pode fazer?)
   ┌────────────────────────────────────────────────┐
   │ • JwtAuthGuard em todas as rotas protegidas    │
   │ • Extração do userId do token                  │
   │ • Verificação de propriedade dos arquivos      │
   │   (key.startsWith(userId/))                    │
   └────────────────────────────────────────────────┘

3. VALIDAÇÃO DE DADOS
   ┌────────────────────────────────────────────────┐
   │ • class-validator nos DTOs                     │
   │ • Email válido obrigatório                     │
   │ • Senha mínima de 6 caracteres                 │
   │ • Nome obrigatório                             │
   └────────────────────────────────────────────────┘

4. CRIPTOGRAFIA
   ┌────────────────────────────────────────────────┐
   │ • Bcrypt para hash de senhas                   │
   │ • Salt rounds = 10                             │
   │ • Senha nunca armazenada em texto plano        │
   └────────────────────────────────────────────────┘

5. ISOLAMENTO DE DADOS
   ┌────────────────────────────────────────────────┐
   │ • Arquivos separados por usuário (S3)          │
   │ • Verificação de propriedade antes de          │
   │   download/delete                              │
   │ • Retorna 403 Forbidden se tentar acessar      │
   │   arquivo de outro usuário                     │
   └────────────────────────────────────────────────┘

6. CORS
   ┌────────────────────────────────────────────────┐
   │ • Apenas http://localhost:3000 permitido       │
   │ • Credentials habilitado                       │
   └────────────────────────────────────────────────┘
```

---

## Tecnologias e Suas Funções

```
┌──────────────────────────────────────────────────────────┐
│                        STACK                             │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  FRONTEND                                                │
│  ┌────────────┬──────────────────────────────────────┐  │
│  │ Next.js    │ Framework React com SSR e routing    │  │
│  │ React      │ UI Components                        │  │
│  │ TypeScript │ Tipagem estática                     │  │
│  │ Axios      │ HTTP Client                          │  │
│  │ CSS Module │ Estilos isolados por componente      │  │
│  └────────────┴──────────────────────────────────────┘  │
│                                                          │
│  BACKEND                                                 │
│  ┌────────────┬──────────────────────────────────────┐  │
│  │ NestJS     │ Framework Node.js estruturado        │  │
│  │ TypeScript │ Tipagem estática                     │  │
│  │ Passport   │ Autenticação                         │  │
│  │ JWT        │ Tokens stateless                     │  │
│  │ Bcrypt     │ Hash de senhas                       │  │
│  │ Multer     │ Upload de arquivos                   │  │
│  │ AWS SDK v3 │ Integração com S3 e DynamoDB         │  │
│  └────────────┴──────────────────────────────────────┘  │
│                                                          │
│  INFRAESTRUTURA                                          │
│  ┌────────────┬──────────────────────────────────────┐  │
│  │ LocalStack │ Emulação local da AWS                │  │
│  │ Docker     │ Containerização                      │  │
│  │ S3         │ Armazenamento de objetos             │  │
│  │ DynamoDB   │ Banco NoSQL                          │  │
│  └────────────┴──────────────────────────────────────┘  │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## Comparação: Desenvolvimento vs Produção

```
┌─────────────────────────────────────────────────────────────┐
│                    DESENVOLVIMENTO                          │
├─────────────────────────────────────────────────────────────┤
│ • LocalStack (emulação AWS)                                 │
│ • Endpoint: http://localhost:4566                           │
│ • Credenciais: test/test                                    │
│ • Dados armazenados localmente                              │
│ • Sem custo                                                 │
│ • Rápido para testes                                        │
└─────────────────────────────────────────────────────────────┘

                            ⬇️ MIGRAÇÃO

┌─────────────────────────────────────────────────────────────┐
│                      PRODUÇÃO (AWS)                         │
├─────────────────────────────────────────────────────────────┤
│ • AWS Real                                                  │
│ • Endpoints regionais (ex: s3.us-east-1.amazonaws.com)      │
│ • IAM Roles e Políticas                                     │
│ • Dados na nuvem AWS                                        │
│ • Custo baseado em uso                                      │
│ • Escalabilidade automática                                 │
│                                                             │
│ MUDANÇAS NECESSÁRIAS:                                       │
│ 1. Remover AWS_ENDPOINT do .env                             │
│ 2. Configurar IAM credentials reais                         │
│ 3. Remover forcePathStyle do S3Client                       │
│ 4. Configurar bucket em região específica                   │
│ 5. Configurar DynamoDB em região específica                 │
│ 6. Habilitar HTTPS                                          │
│ 7. Configurar domínio e DNS                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## Logs e Monitoramento

### Backend inicia

```
🚀 Backend rodando na porta 3001
✅ Bucket my-app-bucket já existe  (ou criado com sucesso)
✅ Tabela users já existe          (ou criada com sucesso)
```

### Operações de Autenticação

```
[AuthService] Novo usuário registrado: email@exemplo.com
[AuthService] Login bem-sucedido: email@exemplo.com
```

### Operações de Arquivos

```
[S3Service] Upload: userId/1697384400000-foto.jpg
[S3Service] Download: userId/1697384400000-foto.jpg
[S3Service] Delete: userId/1697384400000-foto.jpg
[S3Service] Listando arquivos para userId: 550e8400...
```

### Erros Comuns

```
❌ LocalStack não está rodando
   → Solução: docker-compose up -d

❌ Erro ao criar bucket: BucketAlreadyExists
   → Normal: bucket já existe

❌ Erro ao criar tabela: ResourceInUseException
   → Normal: tabela já existe

❌ UnauthorizedException: JWT malformed
   → Solução: Limpar localStorage e fazer login novamente

❌ ForbiddenException: Você não tem permissão...
   → Tentativa de acessar arquivo de outro usuário
```

---

Pronto! Agora você tem uma visão completa da arquitetura do sistema! 🎉
