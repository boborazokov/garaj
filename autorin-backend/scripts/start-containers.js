const fs = require('fs');
const path = require('path');
const { ConsoleLogger } = require('@nestjs/common');
const {
  runContainer,
  checkForOrphanContainers,
} = require('./container-controller.js');
const { setupDocker } = require('./setup-docker.js');
const { services, envFile } = require('./config.js');
const { name: appName } = require('../package.json');

function ensureEnvFile() {
  const logger = new ConsoleLogger('Env', { timestamp: true });
  const dest = path.resolve(__dirname, '..', envFile);
  const example = path.resolve(__dirname, '..', '.env.example');

  if (fs.existsSync(dest)) {
    return dest;
  }

  if (!fs.existsSync(example)) {
    logger.error(
      `Missing ${envFile}. Copy .env.example to ${envFile} and fill in local values.`,
    );
    process.exit(1);
  }

  fs.copyFileSync(example, dest);
  logger.log(`Created ${envFile} from .env.example`);
  return dest;
}

async function startContainers() {
  ensureEnvFile();
  await setupDocker();

  const containers = Object.values(services);
  checkForOrphanContainers(containers, { appName });

  const servicesFiles = Object.keys(services);

  for (let index = 0; index < servicesFiles.length; index++) {
    const service = servicesFiles[index];

    await runContainer(service, {
      appName,
      servicesCount: servicesFiles.length,
      serviceNumber: index + 1,
    });
  }
}

process.stdout.write('\x1Bc');
startContainers();
