import { adminScenes } from './admin';
import { superAdminScenes } from './super-admin';

export const scenes = [...superAdminScenes, ...adminScenes];
