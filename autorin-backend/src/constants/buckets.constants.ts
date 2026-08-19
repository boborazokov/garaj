export enum Bucket {
  USERS = 'users',
  PARTS = 'parts',
  TUNINGS = 'tunings',
  WORKSHOPS = 'workshops',
  SERVICES = 'services',
  CATEGORIES = 'categories',
  ANNOUNCEMENTS = 'announcements',
  ADVERTISEMENTS = 'advertisements',
  ORDERS = 'orders',
  CHATS = 'chats',
}

export enum Catalog {
  USERS_AVATARS = `${Bucket.USERS}/avatars`,
  PARTS_IMAGES = `${Bucket.PARTS}/images`,
  TUNINGS_IMAGES = `${Bucket.TUNINGS}/images`,
  WORKSHOPS_IMAGES = `${Bucket.WORKSHOPS}/images`,
  SERVICES_IMAGES = `${Bucket.SERVICES}/images`,
  CATEGORIES_ICONS = `${Bucket.CATEGORIES}/icons`,
  ANNOUNCEMENTS_IMAGES = `${Bucket.ANNOUNCEMENTS}/images`,
  ADVERTISEMENTS_BANNERS = `${Bucket.ADVERTISEMENTS}/banners`,
  ORDERS_IMAGES = `${Bucket.ORDERS}/images`,
  CHATS_IMAGES = `${Bucket.CHATS}/images`,
  CHATS_VOICES = `${Bucket.CHATS}/voices`,
}
