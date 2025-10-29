# 🚀 Desafio: File Ingestor com LocalStack

## Objetivo

Pipeline local completo onde:
1. Arquivo é enviado para bucket S3 (`ingestor-raw`)
2. Lambda é disparada automaticamente por evento `ObjectCreated`
3. Lambda extrai metadados, calcula checksum SHA256, grava no DynamoDB
4. Lambda move arquivo para bucket `ingestor-processed`
5. API Gateway + Lambda expõe endpoints para consultar arquivos processados

## Arquitetura

```
┌─────────────┐
│   Upload    │
│  to S3 raw  │
└──────┬──────┘
       │ ObjectCreated event
       ▼
┌─────────────────────┐
│  Lambda: ingest     │
│  - Lê objeto        │
│  - Calcula SHA256   │
│  - Grava DynamoDB   │
│  - Move para        │
│    processed bucket │
└──────┬──────────────┘
       │
       ▼
┌─────────────────┐        ┌────────────────┐
│  DynamoDB       │◄───────│  API Gateway   │
│  Table: files   │        │  + Lambda API  │
│  PK: file#{key} │        │  GET /files    │
│  status, size,  │        │  GET /files/id │
│  checksum, etc. │        └────────────────┘
└─────────────────┘
```

## Stack Utilizada

- **LocalStack** - Emula S3, DynamoDB, Lambda, API Gateway
- **Node.js** - Runtime das Lambdas
- **AWS SDK v3** - Cliente para serviços AWS
- **Docker** - Containerização do LocalStack

## Estrutura do Projeto

```
infra/
├── lambdas/
│   ├── ingest/
│   │   └── index.js          # Lambda que processa uploads
│   └── api/
│       └── index.js          # Lambda da API (GET /files)
├── create-resources.ps1       # Cria buckets e tabela DynamoDB
├── deploy-lambdas.ps1         # Deploy das Lambdas e API Gateway
├── test-flow.ps1              # Teste automatizado do fluxo
├── s3-notification.json       # Config do trigger S3->Lambda
└── README.md                  # Este arquivo
```

## Recursos Criados

### Buckets S3
- `ingestor-raw` - Entrada de arquivos
- `ingestor-processed` - Arquivos processados

### Tabela DynamoDB: `files`
- **PK**: `pk` (String) - formato: `file#{object_key}`
- **Atributos**:
  - `bucket` - Nome do bucket atual
  - `key` - Chave do objeto
  - `size` - Tamanho em bytes
  - `etag` - ETag do S3
  - `status` - `RAW` ou `PROCESSED`
  - `checksum` - SHA256 do arquivo
  - `processedAt` - Timestamp ISO (quando processado)
  - `contentType` - MIME type (se disponível)

### Lambdas
1. **ingest** - Processa uploads no bucket raw
   - Trigger: S3 ObjectCreated em `ingestor-raw`
   - Ações:
     - Lê objeto do S3
     - Calcula SHA256
     - Grava item no DynamoDB (status=RAW)
     - Copia para `ingestor-processed/processed/{key}`
     - Deleta do bucket raw
     - Atualiza DynamoDB (status=PROCESSED, processedAt)

2. **files-api** - API para consultar arquivos
   - Endpoints via API Gateway:
     - `GET /files` - Lista com filtros opcionais:
       - `?status=PROCESSED`
       - `?from=2025-01-01&to=2025-12-31`
       - `?limit=50&page=0`
     - `GET /files/{id}` - Retorna item específico por pk

## Como Executar

### Pré-requisitos

1. **Docker Desktop** rodando
2. **Node.js 18+**
3. **awslocal** ou **AWS CLI v2**:
   ```powershell
   # Instalar awslocal (recomendado)
   pip install awscli-local
   
   # OU AWS CLI v2
   winget install Amazon.AWSCLI
   ```

### Execução Completa (Um comando)

Na raiz do projeto:
```powershell
.\start-all.ps1
```

Isso irá:
- Subir LocalStack (Docker)
- Criar buckets e tabela
- Deploy das Lambdas
- Configurar triggers
- Subir backend e frontend

### Execução Manual (Passo a passo)

```powershell
# 1. Subir LocalStack
docker-compose up -d

# 2. Aguardar inicialização
Start-Sleep -Seconds 10

# 3. Criar recursos
cd infra
.\create-resources.ps1

# 4. Deploy das Lambdas
.\deploy-lambdas.ps1

# 5. Testar o fluxo
.\test-flow.ps1
```

### Derrubar tudo

```powershell
.\stop-all.ps1
```

## Teste Automatizado

O script `infra/test-flow.ps1` realiza:
1. Cria arquivo de teste local
2. Upload para `s3://ingestor-raw/test/...`
3. Aguarda Lambda processar (15s)
4. Verifica item no DynamoDB
5. Verifica arquivo em `ingestor-processed`
6. Testa API Gateway GET /files
7. Faz limpeza

```powershell
cd infra
.\test-flow.ps1
```

Saída esperada:
```
=== File Ingestor - Teste Automatizado ===

1. Criando arquivo de teste...
2. Upload para bucket ingestor-raw...
   ✓ Arquivo enviado: test/20251022-223045-test-file.txt
3. Aguardando Lambda processar (15s)...
4. Verificando item no DynamoDB...
   ✓ Item encontrado no DynamoDB!
   PK: file#test/20251022-223045-test-file.txt
   Status: PROCESSED
   Checksum: a1b2c3...
   ProcessedAt: 2025-10-22T22:31:00.123Z
5. Verificando bucket ingestor-processed...
   ✓ Arquivo encontrado em ingestor-processed!
6. Testando API Gateway (GET /files)...
   ✓ API retornou 1 item(s)
7. Limpeza...
   ✓ Arquivo de teste removido

=== Teste concluído ===
```

## Comandos Úteis

```powershell
# Listar buckets
awslocal s3 ls

# Listar objetos em bucket
awslocal s3 ls s3://ingestor-raw/
awslocal s3 ls s3://ingestor-processed/

# Scan tabela DynamoDB
awslocal dynamodb scan --table-name files

# Ver item específico
awslocal dynamodb get-item --table-name files --key '{"pk":{"S":"file#test/myfile.txt"}}'

# Listar Lambdas
awslocal lambda list-functions

# Ver logs do LocalStack
docker logs localstack-main --tail 100

# Invocar Lambda manualmente
awslocal lambda invoke --function-name ingest output.json
```

## Decisões Técnicas

### Por que LocalStack?
- Emulação local completa da AWS
- Sem custos
- Desenvolvimento/teste rápido
- Persistência de dados entre restarts

### Por que Node.js para Lambdas?
- Startup rápido
- AWS SDK v3 nativo
- Simplicidade para operações de stream (cálculo de checksum)

### Por que mover arquivo em vez de prefixo/tags?
- Demonstra operações de cópia e deleção no S3
- Separação clara entre raw e processed
- Facilita filtros e limpeza

### Por que DynamoDB com PK composta?
- Formato `file#{key}` permite queries eficientes
- Escalabilidade horizontal
- Schema flexível para adicionar atributos

### Limitações conhecidas
- Scan no DynamoDB (não usa índice GSI) - OK para ambiente local/teste
- Filtros de data são client-side - para produção, usar GSI com `processedAt` como SK
- Sem retry/DLQ - para produção, adicionar SQS DLQ e exponential backoff

## Melhorias Futuras

- [ ] Adicionar GSI no DynamoDB para queries por `status` e `processedAt`
- [ ] Implementar SQS DLQ para falhas na Lambda
- [ ] Adicionar métricas e logs estruturados (CloudWatch/Datadog)
- [ ] Testes unitários (Jest) para as Lambdas
- [ ] CI/CD pipeline (GitHub Actions)
- [ ] Versionamento de Lambdas e blue/green deployment
- [ ] Rate limiting na API Gateway
- [ ] Autenticação/autorização (Cognito ou API Keys)

## Troubleshooting

**Erro: AWS CLI não encontrado**
```powershell
pip install awscli-local
```

**Erro: LocalStack não está rodando**
```powershell
docker-compose up -d
docker ps  # verificar se container está running
```

**Lambda não está sendo disparada**
```powershell
# Verificar notificação S3
awslocal s3api get-bucket-notification-configuration --bucket ingestor-raw

# Ver logs
docker logs localstack-main --tail 50 --follow
```

**API Gateway não responde**
```powershell
# Listar APIs
awslocal apigatewayv2 get-apis

# Testar diretamente a Lambda
awslocal lambda invoke --function-name files-api output.json --payload '{"path":"/files","httpMethod":"GET"}'
cat output.json
```

## Evidências

Ver diretório `/screenshots` (a ser adicionado) para capturas de tela do fluxo completo.

## Autor

Implementação do desafio "File Ingestor" com LocalStack para fins educacionais.

---

**Repositório**: https://github.com/Joao-Victordss/implementa-o-localstack
