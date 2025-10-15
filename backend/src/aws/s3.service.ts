import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import {
  S3Client,
  PutObjectCommand,
  GetObjectCommand,
  ListObjectsV2Command,
  DeleteObjectCommand,
  CreateBucketCommand,
  HeadBucketCommand,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

@Injectable()
export class S3Service implements OnModuleInit {
  private readonly logger = new Logger(S3Service.name);
  private s3Client: S3Client;
  private bucketName: string;

  constructor() {
    this.bucketName = process.env.S3_BUCKET_NAME || 'my-app-bucket';
    
    const endpoint = process.env.LOCALSTACK_ENDPOINT || process.env.AWS_ENDPOINT || 'http://localhost:4566';
    
    this.logger.log(`🔌 Conectando ao S3 em: ${endpoint}`);
    
    this.s3Client = new S3Client({
      region: process.env.AWS_REGION || 'us-east-1',
      endpoint: endpoint,
      credentials: {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID || 'test',
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || 'test',
      },
      forcePathStyle: true, // Necessário para o LocalStack
    });
  }

  async onModuleInit() {
    try {
      await this.createBucketIfNotExists();
    } catch (error) {
      this.logger.error('❌ Falha ao conectar com S3 (LocalStack não está rodando?)');
      this.logger.error('💡 Solução: Execute "docker-compose up -d" na raiz do projeto');
      this.logger.error(`Detalhes: ${error.message}`);
      this.logger.warn('⚠️  Backend iniciado SEM S3 - funcionalidades de upload não funcionarão');
    }
  }

  private async createBucketIfNotExists() {
    try {
      await this.s3Client.send(new HeadBucketCommand({ Bucket: this.bucketName }));
      this.logger.log(`✅ Bucket ${this.bucketName} já existe`);
    } catch (error) {
      if (error.name === 'NotFound') {
        await this.s3Client.send(new CreateBucketCommand({ Bucket: this.bucketName }));
        this.logger.log(`✅ Bucket ${this.bucketName} criado com sucesso`);
      } else {
        throw error;
      }
    }
  }

  async uploadFile(file: Express.Multer.File, userId: string): Promise<string> {
    const key = `${userId}/${Date.now()}-${file.originalname}`;
    
    const command = new PutObjectCommand({
      Bucket: this.bucketName,
      Key: key,
      Body: file.buffer,
      ContentType: file.mimetype,
      Metadata: {
        originalName: file.originalname,
        userId: userId,
      },
    });

    await this.s3Client.send(command);
    return key;
  }

  async getFile(key: string): Promise<Buffer> {
    const command = new GetObjectCommand({
      Bucket: this.bucketName,
      Key: key,
    });

    const response = await this.s3Client.send(command);
    const stream = response.Body as any;
    
    return new Promise((resolve, reject) => {
      const chunks: any[] = [];
      stream.on('data', (chunk: any) => chunks.push(chunk));
      stream.on('error', reject);
      stream.on('end', () => resolve(Buffer.concat(chunks)));
    });
  }

  async listUserFiles(userId: string) {
    const command = new ListObjectsV2Command({
      Bucket: this.bucketName,
      Prefix: `${userId}/`,
    });

    const response = await this.s3Client.send(command);
    
    return (response.Contents || []).map(item => ({
      key: item.Key,
      size: item.Size,
      lastModified: item.LastModified,
      name: item.Key?.split('/').pop() || '',
    }));
  }

  async deleteFile(key: string): Promise<void> {
    const command = new DeleteObjectCommand({
      Bucket: this.bucketName,
      Key: key,
    });

    await this.s3Client.send(command);
  }

  async getSignedDownloadUrl(key: string): Promise<string> {
    const command = new GetObjectCommand({
      Bucket: this.bucketName,
      Key: key,
    });

    return await getSignedUrl(this.s3Client, command, { expiresIn: 3600 });
  }
}
