# 📁 Índice de Arquivos do Projeto

## 📚 Documentação Principal

| Arquivo | Descrição |
|---------|-----------|
| [README.md](README.md) | **COMECE AQUI!** Documentação completa do projeto com instruções de instalação e uso |
| [QUICKSTART.md](QUICKSTART.md) | Guia rápido de 5 minutos para iniciar o sistema |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Diagramas e explicação detalhada da arquitetura |
| [DEPENDENCIES.md](DEPENDENCIES.md) | Lista completa de todas as dependências e como configurar DynamoDB e S3 |
| [COMMANDS.md](COMMANDS.md) | Referência rápida de comandos úteis |

## 🚀 Scripts de Configuração

| Arquivo | Descrição |
|---------|-----------|
| [setup.ps1](setup.ps1) | Script PowerShell para configuração automática (Windows) |
| [setup.sh](setup.sh) | Script Bash para configuração automática (Linux/Mac) |
| [check-localstack.ps1](check-localstack.ps1) | Script para verificar status do LocalStack |
| [docker-compose.yml](docker-compose.yml) | Configuração do Docker para LocalStack |

## 🔧 Backend (NestJS)

### Configuração
- `backend/package.json` - Dependências e scripts do backend
- `backend/tsconfig.json` - Configuração do TypeScript
- `backend/nest-cli.json` - Configuração do NestJS CLI
- `backend/.env` - Variáveis de ambiente (LocalStack, JWT, etc.)
- `backend/.env.example` - Exemplo de variáveis de ambiente
- `backend/.gitignore` - Arquivos ignorados pelo Git

### Código Principal
- `backend/src/main.ts` - Ponto de entrada da aplicação
- `backend/src/app.module.ts` - Módulo raiz do NestJS

### Módulo AWS
- `backend/src/aws/aws.module.ts` - Módulo global para S3 e DynamoDB
- `backend/src/aws/s3.service.ts` - Serviço para operações com S3
- `backend/src/aws/dynamodb.service.ts` - Serviço para operações com DynamoDB

### Módulo Auth (Autenticação)
- `backend/src/auth/auth.module.ts` - Módulo de autenticação
- `backend/src/auth/auth.controller.ts` - Endpoints de registro e login
- `backend/src/auth/auth.service.ts` - Lógica de autenticação
- `backend/src/auth/dto/auth.dto.ts` - DTOs para validação
- `backend/src/auth/strategies/jwt.strategy.ts` - Estratégia JWT do Passport
- `backend/src/auth/guards/jwt-auth.guard.ts` - Guard de autenticação

### Módulo Files (Upload/Download)
- `backend/src/files/files.module.ts` - Módulo de arquivos
- `backend/src/files/files.controller.ts` - Endpoints de upload/download
- `backend/src/files/files.service.ts` - Lógica de gerenciamento de arquivos

## 🎨 Frontend (Next.js)

### Configuração
- `frontend/package.json` - Dependências e scripts do frontend
- `frontend/tsconfig.json` - Configuração do TypeScript
- `frontend/next.config.js` - Configuração do Next.js
- `frontend/.env.local` - Variáveis de ambiente
- `frontend/.gitignore` - Arquivos ignorados pelo Git

### Páginas
- `frontend/src/pages/_app.tsx` - Componente raiz do Next.js
- `frontend/src/pages/index.tsx` - Página inicial (redirecionamento)
- `frontend/src/pages/login.tsx` - Página de login
- `frontend/src/pages/register.tsx` - Página de registro
- `frontend/src/pages/dashboard.tsx` - Dashboard (upload/download)

### Serviços
- `frontend/src/services/api.ts` - Cliente HTTP (Axios) e serviços de API

### Estilos
- `frontend/src/styles/globals.css` - Estilos globais
- `frontend/src/styles/Auth.module.css` - Estilos das páginas de autenticação
- `frontend/src/styles/Dashboard.module.css` - Estilos do dashboard

## 📊 Estrutura Completa

```
S3/
├── 📄 README.md                    # Documentação principal
├── 📄 QUICKSTART.md                # Guia rápido
├── 📄 ARCHITECTURE.md              # Arquitetura do sistema
├── 📄 DEPENDENCIES.md              # Guia de dependências
├── 📄 COMMANDS.md                  # Referência de comandos
├── 📄 INDEX.md                     # Este arquivo
├── 📄 docker-compose.yml           # Configuração Docker
├── 📄 .gitignore                   # Git ignore global
├── 🔧 setup.ps1                    # Setup Windows
├── 🔧 setup.sh                     # Setup Linux/Mac
├── 🔧 check-localstack.ps1         # Verificar LocalStack
│
├── 📁 backend/                     # Backend NestJS
│   ├── 📄 package.json
│   ├── 📄 tsconfig.json
│   ├── 📄 nest-cli.json
│   ├── 📄 .env
│   ├── 📄 .env.example
│   ├── 📄 .gitignore
│   │
│   └── 📁 src/
│       ├── 📄 main.ts
│       ├── 📄 app.module.ts
│       │
│       ├── 📁 aws/
│       │   ├── 📄 aws.module.ts
│       │   ├── 📄 s3.service.ts
│       │   └── 📄 dynamodb.service.ts
│       │
│       ├── 📁 auth/
│       │   ├── 📄 auth.module.ts
│       │   ├── 📄 auth.controller.ts
│       │   ├── 📄 auth.service.ts
│       │   ├── 📁 dto/
│       │   │   └── 📄 auth.dto.ts
│       │   ├── 📁 strategies/
│       │   │   └── 📄 jwt.strategy.ts
│       │   └── 📁 guards/
│       │       └── 📄 jwt-auth.guard.ts
│       │
│       └── 📁 files/
│           ├── 📄 files.module.ts
│           ├── 📄 files.controller.ts
│           └── 📄 files.service.ts
│
└── 📁 frontend/                    # Frontend Next.js
    ├── 📄 package.json
    ├── 📄 tsconfig.json
    ├── 📄 next.config.js
    ├── 📄 .env.local
    ├── 📄 .gitignore
    │
    └── 📁 src/
        ├── 📁 pages/
        │   ├── 📄 _app.tsx
        │   ├── 📄 index.tsx
        │   ├── 📄 login.tsx
        │   ├── 📄 register.tsx
        │   └── 📄 dashboard.tsx
        │
        ├── 📁 services/
        │   └── 📄 api.ts
        │
        └── 📁 styles/
            ├── 📄 globals.css
            ├── 📄 Auth.module.css
            └── 📄 Dashboard.module.css
```

## 🎯 Onde Encontrar o Quê?

### Precisa entender como funciona?
→ [ARCHITECTURE.md](ARCHITECTURE.md)

### Quer saber todas as dependências?
→ [DEPENDENCIES.md](DEPENDENCIES.md)

### Precisa de comandos rápidos?
→ [COMMANDS.md](COMMANDS.md)

### Quer começar agora?
→ [QUICKSTART.md](QUICKSTART.md)

### Documentação completa?
→ [README.md](README.md)

### Como criar uma conta?
→ Ver seção "Como Usar o Sistema" no [README.md](README.md)

### Como fazer upload?
→ Ver seção "Upload de Arquivos" no [README.md](README.md)

### Configurar LocalStack?
→ Ver seção "Configuração do DynamoDB" e "Configuração do S3" no [DEPENDENCIES.md](DEPENDENCIES.md)

### Verificar se está tudo funcionando?
→ Executar `.\check-localstack.ps1`

### Problemas comuns?
→ Ver seção "Troubleshooting" no [README.md](README.md)

## 📝 Notas Importantes

1. **Sempre comece pelo [QUICKSTART.md](QUICKSTART.md)** se quiser iniciar rapidamente
2. **Leia o [README.md](README.md)** para entender o projeto completo
3. **Consulte [DEPENDENCIES.md](DEPENDENCIES.md)** para entender DynamoDB e S3
4. **Use [COMMANDS.md](COMMANDS.md)** como referência durante o desenvolvimento

## 🔄 Ordem Recomendada de Leitura

Para novos usuários:
1. [QUICKSTART.md](QUICKSTART.md) - Para começar rapidamente
2. [README.md](README.md) - Para entender o projeto
3. [ARCHITECTURE.md](ARCHITECTURE.md) - Para ver como funciona
4. [DEPENDENCIES.md](DEPENDENCIES.md) - Para detalhes técnicos
5. [COMMANDS.md](COMMANDS.md) - Para referência

## 📞 Ajuda Rápida

| Problema | Arquivo |
|----------|---------|
| Como instalar? | [QUICKSTART.md](QUICKSTART.md) |
| Erro no LocalStack | [README.md](README.md) → Troubleshooting |
| Entender DynamoDB | [DEPENDENCIES.md](DEPENDENCIES.md) → Configuração do DynamoDB |
| Entender S3 | [DEPENDENCIES.md](DEPENDENCIES.md) → Configuração do S3 |
| Ver comandos AWS | [COMMANDS.md](COMMANDS.md) → S3 Commands / DynamoDB Commands |
| Entender fluxo | [ARCHITECTURE.md](ARCHITECTURE.md) → Fluxos |

---

**Dica**: Mantenha este arquivo aberto em outra aba para navegação rápida! 🚀
