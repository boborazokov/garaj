import { UserRoleEnum } from 'src/modules/user/enums';

export type RoleMetadataPayload = Record<keyof typeof UserRoleEnum, boolean>;
