import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { S3Service } from '../aws/s3.service';
import { Response } from 'express';

@Injectable()
export class FilesService {
  constructor(private s3Service: S3Service) {}

  async uploadFile(file: Express.Multer.File, userId: string) {
    const key = await this.s3Service.uploadFile(file, userId);

    return {
      message: 'Arquivo enviado com sucesso',
      key,
      originalName: file.originalname,
      size: file.size,
      mimetype: file.mimetype,
    };
  }

  async listUserFiles(userId: string) {
    const files = await this.s3Service.listUserFiles(userId);
    return { files };
  }

  async downloadFile(key: string, userId: string, res: Response) {
    // Verificar se o arquivo pertence ao usuário
    if (!key.startsWith(`${userId}/`)) {
      throw new ForbiddenException('Você não tem permissão para acessar este arquivo');
    }

    try {
      const fileBuffer = await this.s3Service.getFile(key);
      const fileName = key.split('/').pop();

      res.set({
        'Content-Type': 'application/octet-stream',
        'Content-Disposition': `attachment; filename="${fileName}"`,
      });

      res.send(fileBuffer);
    } catch (error) {
      throw new NotFoundException('Arquivo não encontrado');
    }
  }

  async deleteFile(key: string, userId: string) {
    // Verificar se o arquivo pertence ao usuário
    if (!key.startsWith(`${userId}/`)) {
      throw new ForbiddenException('Você não tem permissão para excluir este arquivo');
    }

    try {
      await this.s3Service.deleteFile(key);
      return { message: 'Arquivo excluído com sucesso' };
    } catch (error) {
      throw new NotFoundException('Arquivo não encontrado');
    }
  }
}
