import { Module, Global } from '@nestjs/common';
import { S3Service } from './s3.service';
import { DynamoDbService } from './dynamodb.service';

@Global()
@Module({
  providers: [S3Service, DynamoDbService],
  exports: [S3Service, DynamoDbService],
})
export class AwsModule {}
