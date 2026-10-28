import { UserRoleEnum } from '../enums';

export type DefaultStaffAccount = {
  name: string;
  phone: string;
  password: string;
  role: UserRoleEnum;
};

export const DEFAULT_STAFF_PASSWORD = '12345678';

export const DEFAULT_STAFF_ACCOUNTS: DefaultStaffAccount[] = [
  {
    name: 'Admin',
    phone: '+998905165599',
    password: DEFAULT_STAFF_PASSWORD,
    role: UserRoleEnum.ADMIN,
  },
  {
    name: 'Moderator',
    phone: '+998901234567',
    password: DEFAULT_STAFF_PASSWORD,
    role: UserRoleEnum.MODERATOR,
  },
];
