import {
  Controller,
  Post,
  Get,
  Delete,
  Param,
  UseGuards,
  UseInterceptors,
  UploadedFile,
  Request,
  Response,
  BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { FilesService } from './files.service';

@Controller('files')
@UseGuards(JwtAuthGuard)
export class FilesController {
  constructor(private filesService: FilesService) {}

  @Post('upload')
  @UseInterceptors(FileInterceptor('file'))
  async uploadFile(
    @UploadedFile() file: Express.Multer.File,
    @Request() req,
  ) {
    if (!file) {
      throw new BadRequestException('Nenhum arquivo foi enviado');
    }

    return this.filesService.uploadFile(file, req.user.userId);
  }

  @Get('list')
  async listFiles(@Request() req) {
    return this.filesService.listUserFiles(req.user.userId);
  }

  @Get('download/:key(*)')
  async downloadFile(
    @Param('key') key: string,
    @Request() req,
    @Response() res,
  ) {
    return this.filesService.downloadFile(key, req.user.userId, res);
  }

  @Delete(':key(*)')
  async deleteFile(
    @Param('key') key: string,
    @Request() req,
  ) {
    return this.filesService.deleteFile(key, req.user.userId);
  }
}
