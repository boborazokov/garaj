import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { FileUpload } from 'graphql-upload-ts';
import { User } from '../schema';
import { Part } from 'src/modules/part/schema';
import { Workshop } from 'src/modules/workshop/schema';
import { Catalog, COLLECTIONS } from 'src/constants';
import { ContextType } from 'src/auth/interfaces';
import { UpdateProfileArgs } from '../dto';
import { MinioService } from 'src/utils/minio';
import { ItemStatusEnum } from 'src/modules/item/enums';
import { DeleteAccountResult } from '../types';
import { SessionService } from 'src/modules/auth/session/session.service';
import {
  normalizeUzPhone,
  uzPhoneLookupVariants,
} from 'src/shared/utils/normalize-uz-phone';
import { DEFAULT_STAFF_ACCOUNTS } from '../seed/seed-default-accounts';

@Injectable()
export class UserService {
  constructor(
    @InjectModel(COLLECTIONS.USERS) private userModel: Model<User>,
    @InjectModel(COLLECTIONS.PARTS) private partModel: Model<Part>,
    @InjectModel(COLLECTIONS.WORKSHOPS) private workshopModel: Model<Workshop>,
    private minioService: MinioService,
    private sessions: SessionService,
  ) {}

  async seedDefaultStaffAccounts(): Promise<number> {
    let count = 0;

    for (const account of DEFAULT_STAFF_ACCOUNTS) {
      const phone = normalizeUzPhone(account.phone);
      const existing = await this.userModel.findOne({
        phone: { $in: uzPhoneLookupVariants(phone) },
      });

      if (!existing) {
        const created = new this.userModel({
          name: account.name,
          phone,
          password: account.password,
          role: account.role,
        });
        await created.save();
        count += 1;
        continue;
      }

      existing.phone = phone;
      existing.password = account.password;
      existing.role = account.role;
      existing.deletedAt = null;
      await existing.save();
      count += 1;
    }

    return count;
  }

  async getProfile({ userId }: ContextType) {
    const foundUser = await this.userModel.findById(userId);

    if (!foundUser) {
      throw new Error('User not found');
    }

    return foundUser;
  }

  async uploadUserImage(
    image: Promise<FileUpload>,
    oldImageUrl?: string | null,
  ): Promise<string> {
    if (oldImageUrl) {
      try {
        await this.minioService.deleteFileFromUrl(oldImageUrl);
      } catch {
        // A broken stored path must not block the new photo.
      }
    }

    const file = await this.minioService.prepareFile({
      file: await image,
      compress: false,
    });

    try {
      return await this.minioService.uploadFile({
        ...file,
        catalog: Catalog.USERS_AVATARS,
        compress: true,
      });
    } catch {
      return this.minioService.uploadFile({
        ...file,
        catalog: Catalog.USERS_AVATARS,
        compress: false,
      });
    }
  }

  async updateProfile(
    { data, image }: UpdateProfileArgs,
    { userId }: ContextType,
  ) {
    const user = await this.userModel.findById(userId);
    if (!user) {
      throw new BadRequestException('User not found');
    }

    const patch: Partial<User> = { ...data };

    if (image) {
      patch.image = await this.uploadUserImage(image, user.image);
    }

    const updatedUser = await this.userModel.findByIdAndUpdate(
      userId,
      {
        $set: patch,
        $unset: { username: '', bio: '', description: '', email: '' },
      },
      { new: true },
    );

    if (!updatedUser) {
      throw new BadRequestException('User not found');
    }

    return updatedUser;
  }

  async setUserImageByAdmin(userId: Types.ObjectId, image: Promise<FileUpload>) {
    const user = await this.userModel.findById(userId);
    if (!user) {
      throw new BadRequestException('User not found');
    }

    const imageUrl = await this.uploadUserImage(image, user.image);

    const updated = await this.userModel.findByIdAndUpdate(
      userId,
      { $set: { image: imageUrl } },
      { new: true },
    );

    if (!updated) {
      throw new BadRequestException('User not found');
    }

    return updated;
  }

  /**
   * Permanently removes personal data and archives the user's listings.
   * Required for Apple App Store account-deletion guidelines.
   */
  async deleteMyAccount({ userId }: ContextType): Promise<DeleteAccountResult> {
    const user = await this.userModel.findById(userId);
    if (!user || user.deletedAt) {
      throw new BadRequestException('User not found');
    }

    const uid = new Types.ObjectId(userId);

    if (user.image) {
      try {
        await this.minioService.deleteFileFromUrl(user.image);
      } catch {
        /* best-effort */
      }
    }

    await Promise.all([
      this.partModel.updateMany(
        { seller: uid },
        { $set: { status: ItemStatusEnum.ARCHIVED } },
      ),
      this.workshopModel.updateMany(
        { owner: uid },
        { $set: { status: ItemStatusEnum.ARCHIVED } },
      ),
    ]);

    await this.userModel.findByIdAndUpdate(uid, {
      $set: {
        deletedAt: new Date(),
        name: 'Deleted account',
        phone: `deleted_${uid.toString()}_${Date.now()}`,
        image: null,
        address: '',
        region: '',
        city: '',
        country: '',
      },
      $unset: {
        tgId: '',
        username: '',
        bio: '',
        description: '',
        email: '',
      },
    });

    await this.sessions.revokeAllForUser(uid);
    return { success: true };
  }
}
