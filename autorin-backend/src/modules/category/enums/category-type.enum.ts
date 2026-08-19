import { registerEnumType } from '@nestjs/graphql';

export enum CategoryTypeEnum {
  /**
   * Top-level car make (e.g. Chevrolet, BMW). `parentId` must be null.
   */
  BRAND = 'BRAND',
  /**
   * Car model (e.g. Cobalt, Malibu). `parentId` must point to a BRAND.
   */
  MODEL = 'MODEL',
  /**
   * Part / service / tuning category leaf (e.g. Engine, Brake, Electronics).
   * `parentId` is optional — if present it points to a MODEL.
   */
  PART = 'PART',
  SERVICE = 'SERVICE',
  TUNING = 'TUNING',
  ANNOUNCEMENT = 'ANNOUNCEMENT',
}

registerEnumType(CategoryTypeEnum, {
  name: 'CategoryTypeEnum',
});
