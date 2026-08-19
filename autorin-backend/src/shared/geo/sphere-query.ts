import { FilterQuery } from 'mongoose';
import { GeoJsonPoint } from './geo-point.object';

/** Mean Earth radius in meters (WGS84). */
export const EARTH_RADIUS_METERS = 6_378_137;

export function isValidGeoJsonPoint(
  point?: GeoJsonPoint | { type?: string; coordinates?: unknown } | null,
): point is GeoJsonPoint {
  if (!point || point.type !== 'Point') return false;
  const c = point.coordinates;
  if (!Array.isArray(c) || c.length < 2) return false;
  const lng = c[0];
  const lat = c[1];
  return (
    typeof lng === 'number' &&
    typeof lat === 'number' &&
    Number.isFinite(lng) &&
    Number.isFinite(lat)
  );
}

export type GeoJsonField = 'geo' | 'mapLocation';

/** Exclude documents whose GeoJSON field breaks 2dsphere queries. */
export function validGeoFieldFilter(
  field: GeoJsonField,
): FilterQuery<Record<string, unknown>> {
  return {
    $expr: {
      $and: [
        { $eq: [`$${field}.type`, 'Point'] },
        { $isNumber: { $arrayElemAt: [`$${field}.coordinates`, 0] } },
        { $isNumber: { $arrayElemAt: [`$${field}.coordinates`, 1] } },
      ],
    },
  };
}

export function geoFieldGeoFilter(
  field: GeoJsonField,
  geoCondition: { $geoWithin: Record<string, unknown> },
): FilterQuery<Record<string, unknown>> {
  return {
    $and: [validGeoFieldFilter(field), { [field]: geoCondition }],
  };
}

export function mapLocationGeoFilter(
  geoCondition: { $geoWithin: Record<string, unknown> },
): FilterQuery<Record<string, unknown>> {
  return geoFieldGeoFilter('mapLocation', geoCondition);
}

/** 2dsphere proximity filter for a GeoJSON Point field. */
export function geoWithinCenterSphere(
  longitude: number,
  latitude: number,
  radiusMeters: number,
): { $geoWithin: { $centerSphere: [[number, number], number] } } {
  const radiusRadians = radiusMeters / EARTH_RADIUS_METERS;
  return {
    $geoWithin: {
      $centerSphere: [[longitude, latitude], radiusRadians],
    },
  };
}

export function haversineMeters(
  lng1: number,
  lat1: number,
  lng2: number,
  lat2: number,
): number {
  const toRad = (d: number) => (d * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return EARTH_RADIUS_METERS * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

export function distanceToGeoJsonPoint(
  longitude: number,
  latitude: number,
  point?: GeoJsonPoint | null,
): number {
  const coords = point?.coordinates;
  if (!coords || coords.length < 2) return Number.POSITIVE_INFINITY;
  return haversineMeters(longitude, latitude, coords[0], coords[1]);
}
