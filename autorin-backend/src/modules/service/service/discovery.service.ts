import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { COLLECTIONS } from 'src/constants';
import { ItemStatusEnum } from 'src/modules/item/enums';
import { OrderStatusEnum } from 'src/modules/order/enums';
import { Order } from 'src/modules/order/schema';
import { Part } from 'src/modules/part/schema';
import {
  distanceToGeoJsonPoint,
  geoFieldGeoFilter,
  geoWithinCenterSphere,
  isValidGeoJsonPoint,
} from 'src/shared/geo';
import { NearbyArgs } from 'src/shared/geo/nearby.args';

@Injectable()
export class MapDiscoveryService {
  constructor(
    @InjectModel(COLLECTIONS.PARTS) private readonly partModel: Model<Part>,
    @InjectModel(COLLECTIONS.ORDERS) private readonly orderModel: Model<Order>,
  ) {}

  async nearbyProducts(args: NearbyArgs) {
    const lat = args.latitude;
    const lng = args.longitude;
    if (!Number.isFinite(lat) || !Number.isFinite(lng)) return [];

    const radiusMeters = (args.radiusKm ?? 15) * 1000;
    const limit = args.limit ?? 40;

    try {
      let docs = await this.partModel
        .find({
          status: ItemStatusEnum.ACTIVE,
          ...geoFieldGeoFilter(
            'geo',
            geoWithinCenterSphere(lng, lat, radiusMeters),
          ),
        })
        .limit(limit + 40)
        .populate({ path: 'seller', select: 'name phone' })
        .lean()
        .exec();

      docs = docs.filter((d) => isValidGeoJsonPoint(d.geo));
      docs.sort(
        (a, b) =>
          distanceToGeoJsonPoint(lng, lat, a.geo) -
          distanceToGeoJsonPoint(lng, lat, b.geo),
      );
      return docs.slice(0, limit);
    } catch {
      return [];
    }
  }

  async nearbyOrders(args: NearbyArgs) {
    const lat = args.latitude;
    const lng = args.longitude;
    if (!Number.isFinite(lat) || !Number.isFinite(lng)) return [];

    const radiusMeters = (args.radiusKm ?? 15) * 1000;
    const limit = args.limit ?? 40;

    try {
      let docs = await this.orderModel
        .find({
          status: OrderStatusEnum.ACTIVE,
          ...geoFieldGeoFilter(
            'geo',
            geoWithinCenterSphere(lng, lat, radiusMeters),
          ),
        })
        .limit(limit + 40)
        .lean()
        .exec();

      docs = docs.filter((d) => isValidGeoJsonPoint(d.geo));
      docs.sort(
        (a, b) =>
          distanceToGeoJsonPoint(lng, lat, a.geo) -
          distanceToGeoJsonPoint(lng, lat, b.geo),
      );
      return docs.slice(0, limit);
    } catch {
      return [];
    }
  }
}
