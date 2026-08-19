import { Field, Float, ObjectType } from '@nestjs/graphql';
import { Schema as MongooseSchema } from 'mongoose';

@ObjectType()
export class GeoPoint {
  @Field(() => Float)
  latitude: number;

  @Field(() => Float)
  longitude: number;
}

/** MongoDB GeoJSON Point document shape. */
export type GeoJsonPoint = {
  type: 'Point';
  coordinates: [number, number]; // [lng, lat]
};

export function toGeoJsonPoint(lat: number, lng: number): GeoJsonPoint {
  return { type: 'Point', coordinates: [lng, lat] };
}

export function fromGeoJsonPoint(geo?: GeoJsonPoint | null): GeoPoint | null {
  if (!geo?.coordinates || geo.coordinates.length < 2) return null;
  return {
    longitude: geo.coordinates[0],
    latitude: geo.coordinates[1],
  };
}

/**
 * Mongoose subdocument schema for a GeoJSON Point.
 *
 * Defined as a real `Schema` (not a plain object) because `@Prop({ type: ... })`
 * combined with extra options (`required`, `index`) causes Mongoose to
 * misinterpret the nested `type` field as a path. Using a Schema instance
 * makes Mongoose treat it as a single typed subdocument.
 */
export const GEO_POINT_SCHEMA = new MongooseSchema(
  {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point',
      required: true,
    },
    coordinates: {
      type: [Number],
      required: true,
    },
  },
  { _id: false },
);
