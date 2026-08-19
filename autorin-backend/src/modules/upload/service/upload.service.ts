import {
  BadRequestException,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import {
  assertUploadAllowed,
  assertVoiceUploadAllowed,
  secureUploadKey,
  secureVoiceUploadKey,
  validateUploadBatch,
} from 'src/common/upload';
import { Catalog, COLLECTIONS } from 'src/constants';
import { Part } from 'src/modules/part/schema';
import { MinioService } from 'src/utils/minio';
import { UploadFileDto, UploadFilesDto } from '../dto';
import { ContextType } from 'src/auth/interfaces';
import { assertAuthenticated } from 'src/auth/utils/authenticated-context';
import { UserRoleEnum } from 'src/modules/user/enums';
import { Order } from 'src/modules/order/schema';
import { Workshop } from 'src/modules/workshop/schema';

@Injectable()
export class UploadService {
  constructor(
    private minioService: MinioService,
    private config: ConfigService,
    @InjectModel(COLLECTIONS.PARTS) private partModel: Model<Part>,
    @InjectModel(COLLECTIONS.WORKSHOPS) private workshopModel: Model<Workshop>,
    @InjectModel(COLLECTIONS.ORDERS) private orderModel: Model<Order>,
  ) {}

  private maxUploadBytes(): number {
    return Number(this.config.get('UPLOAD_MAX_FILE_BYTES') ?? 10_485_760);
  }

  async uploadPartImages(
    images: Express.Multer.File[],
    oldImagesUrls?: string[],
  ) {
    if (oldImagesUrls) {
      for (const oldImageUrl of oldImagesUrls) {
        await this.minioService.deleteFileFromUrl(oldImageUrl);
      }
    }

    const uploadedImagesUrls: string[] = [];

    for (const image of images) {
      assertUploadAllowed(image, this.maxUploadBytes());
      const { fileKey, extension } = secureUploadKey(image.mimetype);
      const uploadedFileUrl = await this.minioService.uploadFile({
        fileBuffer: image.buffer,
        fileKey,
        fileMimetype: image.mimetype,
        catalog: Catalog.PARTS_IMAGES,
        compress: true,
      });

      uploadedImagesUrls.push(uploadedFileUrl);
    }

    return uploadedImagesUrls;
  }

  async updatePartImages(
    partId: string,
    images: Express.Multer.File[],
    { userId }: ContextType,
  ) {
    const part = await this.partModel.findOne({
      _id: new Types.ObjectId(partId),
      seller: new Types.ObjectId(userId),
    });

    if (!part) {
      throw new BadRequestException('Part not found');
    }

    const uploadedImagesUrls = await this.uploadPartImages(images, part.images);

    part.images = uploadedImagesUrls;

    await part.save();

    return true;
  }

  async uploadWorkshopImages(
    images: Express.Multer.File[],
    oldImagesUrls?: string[],
  ) {
    if (oldImagesUrls) {
      for (const oldImageUrl of oldImagesUrls) {
        await this.minioService.deleteFileFromUrl(oldImageUrl);
      }
    }

    const uploadedImagesUrls: string[] = [];

    for (const image of images) {
      assertUploadAllowed(image, this.maxUploadBytes());
      const { fileKey, extension } = secureUploadKey(image.mimetype);
      const uploadedFileUrl = await this.minioService.uploadFile({
        fileBuffer: image.buffer,
        fileKey,
        fileMimetype: image.mimetype,
        catalog: Catalog.WORKSHOPS_IMAGES,
        compress: true,
      });

      uploadedImagesUrls.push(uploadedFileUrl);
    }

    return uploadedImagesUrls;
  }

  async updateWorkshopImages(
    partId: string,
    images: Express.Multer.File[],
    { userId }: ContextType,
  ) {
    const workshop = await this.workshopModel.findOne({
      _id: new Types.ObjectId(partId),
      owner: new Types.ObjectId(userId),
    });

    if (!workshop) {
      throw new BadRequestException('Workshop not found');
    }

    const uploadedImagesUrls = await this.uploadWorkshopImages(
      images,
      workshop.images,
    );

    workshop.images = uploadedImagesUrls;

    await workshop.save();

    return true;
  }

  async uploadOrderImages(images: Express.Multer.File[]) {
    const uploadedImagesUrls: string[] = [];

    for (const image of images) {
      assertUploadAllowed(image, this.maxUploadBytes());
      const { fileKey, extension } = secureUploadKey(image.mimetype);
      const uploadedFileUrl = await this.minioService.uploadFile({
        fileBuffer: image.buffer,
        fileKey,
        fileMimetype: image.mimetype,
        catalog: Catalog.ORDERS_IMAGES,
        compress: true,
      });

      uploadedImagesUrls.push(uploadedFileUrl);
    }

    return uploadedImagesUrls;
  }

  async updateOrderImages(
    orderId: string,
    images: Express.Multer.File[],
    { userId }: ContextType,
  ) {
    const order = await this.orderModel.findOne({
      _id: new Types.ObjectId(orderId),
      author: new Types.ObjectId(userId),
    });

    if (!order) {
      throw new BadRequestException('Order not found');
    }

    const existing = order.images ?? [];
    const remaining = Math.max(0, 5 - existing.length);
    if (remaining === 0) {
      return { files: existing };
    }

    const batch = images.slice(0, remaining);
    const uploadedImagesUrls = await this.uploadOrderImages(batch);
    order.images = [...existing, ...uploadedImagesUrls];
    await order.save();

    return { files: order.images };
  }

  async uploadCategoryIcon(
    file: Express.Multer.File,
    context: ContextType,
  ): Promise<{ files: string[] }> {
    const { userRole } = assertAuthenticated(context);
    if (userRole !== UserRoleEnum.ADMIN) {
      throw new ForbiddenException('Admin access required');
    }
    if (!file) {
      throw new BadRequestException('Image file is required');
    }
    validateUploadBatch([file], this.maxUploadBytes());

    assertUploadAllowed(file, this.maxUploadBytes());
    const { fileKey, extension } = secureUploadKey(file.mimetype);
    const uploadedFileUrl = await this.minioService.uploadFile({
      fileBuffer: file.buffer,
      fileKey,
      fileMimetype: file.mimetype,
      catalog: Catalog.CATEGORIES_ICONS,
      compress: true,
    });

    return { files: [uploadedFileUrl] };
  }

  /**
   * Admin-only banner upload used by the Advertisements page in the web
   * console. Returns the same `{ files: string[] }` shape as
   * `uploadCategoryIcon` so the web client can reuse the existing wrapper.
   */
  async uploadAdvertisementBanner(
    file: Express.Multer.File,
    context: ContextType,
  ): Promise<{ files: string[] }> {
    const { userRole } = assertAuthenticated(context);
    if (userRole !== UserRoleEnum.ADMIN) {
      throw new ForbiddenException('Admin access required');
    }
    if (!file) {
      throw new BadRequestException('Image file is required');
    }
    validateUploadBatch([file], this.maxUploadBytes());

    assertUploadAllowed(file, this.maxUploadBytes());
    const { fileKey } = secureUploadKey(file.mimetype);
    const uploadedFileUrl = await this.minioService.uploadFile({
      fileBuffer: file.buffer,
      fileKey,
      fileMimetype: file.mimetype,
      catalog: Catalog.ADVERTISEMENTS_BANNERS,
      compress: true,
    });

    return { files: [uploadedFileUrl] };
  }

  async uploadFile(
    file: Express.Multer.File,
    { target }: UploadFileDto,
    context: ContextType,
  ): Promise<string> {
    return 'hello';
  }

  /** Upload a single image attached to a chat message. */
  async uploadChatImage(
    file: Express.Multer.File,
    context: ContextType,
  ): Promise<string> {
    assertAuthenticated(context);
    if (!file) {
      throw new BadRequestException('Image file is required');
    }
    assertUploadAllowed(file, this.maxUploadBytes());
    const { fileKey } = secureUploadKey(file.mimetype);
    return this.minioService.uploadFile({
      fileBuffer: file.buffer,
      fileKey,
      fileMimetype: file.mimetype,
      catalog: Catalog.CHATS_IMAGES,
      compress: true,
    });
  }

  /** Upload a voice recording attached to a chat message. */
  async uploadChatVoice(
    file: Express.Multer.File,
    context: ContextType,
  ): Promise<string> {
    assertAuthenticated(context);
    if (!file) {
      throw new BadRequestException('Voice file is required');
    }
    assertVoiceUploadAllowed(file, this.maxUploadBytes());
    const { fileKey } = secureVoiceUploadKey(file.mimetype);
    return this.minioService.uploadFile({
      fileBuffer: file.buffer,
      fileKey,
      fileMimetype: file.mimetype,
      catalog: Catalog.CHATS_VOICES,
      compress: false,
    });
  }

  async uploadMultipleFiles(
    files: Express.Multer.File[],
    { target }: UploadFilesDto,
    context: ContextType,
  ) {
    validateUploadBatch(files, this.maxUploadBytes());

    if (target?.partId) {
      return await this.updatePartImages(target.partId, files, context);
    }
    if (target?.workshopId) {
      return await this.updateWorkshopImages(target.workshopId, files, context);
    }
    if (target?.orderId) {
      return await this.updateOrderImages(target.orderId, files, context);
    }
    throw new BadRequestException('Invalid target for file upload');
  }
}
