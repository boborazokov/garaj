import { COLLECTIONS } from './collections.constants';

export const POPULATIONS = {
  item: [
    {
      path: 'category',
      model: COLLECTIONS.CATEGORIES,
    },
  ],
  part: [
    {
      path: 'seller',
      model: COLLECTIONS.USERS,
    },
  ],
  workshop: [
    {
      path: 'owner',
      model: COLLECTIONS.USERS,
    },
  ],
};
