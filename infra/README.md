File Ingestor infra for LocalStack

Steps:
1. Ensure LocalStack is running: docker-compose up -d
2. Make sure `awslocal` (localstack CLI) is installed and in PATH. Alternatively use AWS CLI with --endpoint-url http://localhost:4566
3. Run resource creation and deploy scripts:

```bash
chmod +x infra/create-resources.sh infra/deploy-lambdas.sh
./infra/create-resources.sh
./infra/deploy-lambdas.sh
```

PowerShell (Windows) alternative:

```powershell
# From project root
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
cd infra
./create-resources.ps1
./deploy-lambdas.ps1
```

4. Test:
- Upload a file to `ingestor-raw` bucket using `awslocal s3 cp file.txt s3://ingestor-raw/yourkey`.
- Check Lambda logs in LocalStack (docker logs localstack-main) and DynamoDB item with `awslocal dynamodb get-item --table-name files --key '{"pk":{"S":"file#yourkey"}}'`.
- Call API: GET http://localhost:4566/restapis/<apiId>/v1/files

Notes:
- Scripts are minimal for the challenge and assume LocalStack's default account/role ARNs.
- The ingest lambda copies objects to `ingestor-processed` and prefixes with `processed/`.
