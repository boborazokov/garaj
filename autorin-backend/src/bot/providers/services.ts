import { app } from 'src/main';
import { MinioService } from 'src/utils/minio';

export const minioService = app.get(MinioService);
