const env = process.env.NODE_ENV || 'development';
const IS_DEV_MODE = env === 'development';
const envFile = IS_DEV_MODE ? '.env.development' : '.env';
const dockerDesktopPath =
  process.env.DOCKER_DESKTOP_PATH ||
  'C:\\Program Files\\Docker\\Docker\\Docker Desktop.exe';

function getBooleanEnv(name, defaultValue = false) {
  const value = process.env[name];

  if (value == null) {
    return defaultValue;
  }

  return ['1', 'true', 'yes', 'on'].includes(value.toLowerCase());
}

const SKIP_DOCKER = getBooleanEnv('SKIP_DOCKER', false);
const AUTO_START_DOCKER = getBooleanEnv('AUTO_START_DOCKER', true);

const services = {
  // mongodb: 'autorin_mongodb',
  redis: 'autorin_redis',
  minio: 'autorin_minio',
  meilisearch: 'autorin_meilisearch',
};

module.exports = {
  env,
  IS_DEV_MODE,
  envFile,
  dockerDesktopPath,
  SKIP_DOCKER,
  AUTO_START_DOCKER,
  services,
};
