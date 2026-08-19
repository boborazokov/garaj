import { BadRequestException, Injectable } from '@nestjs/common';
import { ViewTargetTypeEnum } from '../enums';
import { Model, Types } from 'mongoose';
import { InjectModel } from '@nestjs/mongoose';
import { COLLECTIONS } from 'src/constants';
import { View } from '../schema';
import { GetTargetViewsCountArgs, ViewsTargetInput } from '../dto';

@Injectable()
export class ViewService {
  constructor(
    @InjectModel(COLLECTIONS.VIEWS) private readonly viewModel: Model<View>,
  ) {}

  async getViewsCount(
    targetType: ViewTargetTypeEnum,
    targetId: Types.ObjectId,
  ) {
    const viewsCount = await this.viewModel.countDocuments({
      targetType,
      targetId,
    });

    return viewsCount;
  }

  async incrementViewsCount(
    targetType: ViewTargetTypeEnum,
    targetId: Types.ObjectId,
    userId: Types.ObjectId,
  ) {
    const existingView = await this.viewModel.findOne({
      targetType,
      targetId,
      userId,
    });

    if (existingView) {
      await this.viewModel.create({
        targetType,
        targetId,
        userId,
      });
    }

    return true;
  }

  parseTarget(target: ViewsTargetInput) {
    const { partId } = target;

    if (partId) {
      return {
        _id: partId,
        type: ViewTargetTypeEnum.PART,
      };
    }

    throw new BadRequestException('Invalid target');
  }

  async getTargetViewsCount({ target }: GetTargetViewsCountArgs) {
    const { _id: partId, type } = this.parseTarget(target);

    const viewsCount = await this.getViewsCount(type, partId);

    return viewsCount;
  }
}
