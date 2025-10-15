import { Module } from '@nestjs/common';
import { AuthModule } from './auth/auth.module';
import { FilesModule } from './files/files.module';
import { AwsModule } from './aws/aws.module';

@Module({
  imports: [
    AwsModule,
    AuthModule,
    FilesModule,
  ],
})
export class AppModule {}
