import { FileUpload } from 'graphql-upload-ts';
import { Catalog } from 'src/constants/buckets.constants';

export class GetFileArgs {
  catalog: Catalog;
  fileId: string;
  bucket: string;
}

export class PrepareFileArgs {
  file: FileUpload;
  compress?: boolean;
}

export class UploadFileArgs {
  catalog: Catalog;
  fileKey: string;
  fileBuffer: Buffer;
  fileId?: string;
  fileMimetype: string;
  compress: boolean;
  sizes?: {
    [key: string]: {
      width: number;
      height: number;
    };
  };
}
