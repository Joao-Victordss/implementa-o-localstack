import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import {
  DynamoDBClient,
  CreateTableCommand,
  DescribeTableCommand,
} from '@aws-sdk/client-dynamodb';
import {
  DynamoDBDocumentClient,
  PutCommand,
  GetCommand,
  ScanCommand,
  QueryCommand,
} from '@aws-sdk/lib-dynamodb';

@Injectable()
export class DynamoDbService implements OnModuleInit {
  private readonly logger = new Logger(DynamoDbService.name);
  private client: DynamoDBClient;
  private docClient: DynamoDBDocumentClient;
  private tableName: string;

  constructor() {
    this.tableName = process.env.DYNAMODB_TABLE_NAME || 'users';
    
    const endpoint = process.env.LOCALSTACK_ENDPOINT || process.env.AWS_ENDPOINT || 'http://localhost:4566';
    
    this.logger.log(`🔌 Conectando ao DynamoDB em: ${endpoint}`);
    
    this.client = new DynamoDBClient({
      region: process.env.AWS_REGION || 'us-east-1',
      endpoint: endpoint,
      credentials: {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID || 'test',
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || 'test',
      },
      maxAttempts: 3,
    });

    this.docClient = DynamoDBDocumentClient.from(this.client);
  }

  async onModuleInit() {
    try {
      await this.createTableIfNotExists();
    } catch (error) {
      this.logger.error('❌ Falha ao conectar com DynamoDB (LocalStack não está rodando?)');
      this.logger.error('💡 Solução: Execute "docker-compose up -d" na raiz do projeto');
      this.logger.error(`Detalhes: ${error.message}`);
      this.logger.warn('⚠️  Backend iniciado SEM DynamoDB - funcionalidades de autenticação não funcionarão');
    }
  }

  private async createTableIfNotExists() {
    try {
      await this.client.send(
        new DescribeTableCommand({ TableName: this.tableName })
      );
      this.logger.log(`✅ Tabela ${this.tableName} já existe`);
    } catch (error) {
      if (error.name === 'ResourceNotFoundException') {
        const command = new CreateTableCommand({
          TableName: this.tableName,
          KeySchema: [
            { AttributeName: 'id', KeyType: 'HASH' },
          ],
          AttributeDefinitions: [
            { AttributeName: 'id', AttributeType: 'S' },
            { AttributeName: 'email', AttributeType: 'S' },
          ],
          GlobalSecondaryIndexes: [
            {
              IndexName: 'EmailIndex',
              KeySchema: [
                { AttributeName: 'email', KeyType: 'HASH' },
              ],
              Projection: {
                ProjectionType: 'ALL',
              },
              ProvisionedThroughput: {
                ReadCapacityUnits: 5,
                WriteCapacityUnits: 5,
              },
            },
          ],
          ProvisionedThroughput: {
            ReadCapacityUnits: 5,
            WriteCapacityUnits: 5,
          },
        });

        await this.client.send(command);
        this.logger.log(`✅ Tabela ${this.tableName} criada com sucesso`);
        
        // Aguardar a tabela ficar ativa
        await new Promise(resolve => setTimeout(resolve, 2000));
      } else {
        throw error;
      }
    }
  }

  async putItem(item: any) {
    const command = new PutCommand({
      TableName: this.tableName,
      Item: item,
    });

    return await this.docClient.send(command);
  }

  async getItem(id: string) {
    const command = new GetCommand({
      TableName: this.tableName,
      Key: { id },
    });

    const response = await this.docClient.send(command);
    return response.Item;
  }

  async findByEmail(email: string) {
    const command = new QueryCommand({
      TableName: this.tableName,
      IndexName: 'EmailIndex',
      KeyConditionExpression: 'email = :email',
      ExpressionAttributeValues: {
        ':email': email,
      },
    });

    const response = await this.docClient.send(command);
    return response.Items?.[0];
  }

  async scanItems() {
    const command = new ScanCommand({
      TableName: this.tableName,
    });

    const response = await this.docClient.send(command);
    return response.Items || [];
  }
}
