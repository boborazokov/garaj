const { ConsoleLogger } = require('@nestjs/common');
const path = require('path');
const { execSync } = require('child_process');

const { envFile } = require('./config');
const { runCommand } = require('./cli-utils');

async function runContainer(
  containerName,
  { appName = 'app', servicesCount, serviceNumber } = {},
) {
  const logger = new ConsoleLogger(
    `${containerName} (${serviceNumber} of ${servicesCount})`,
    { timestamp: true },
  );

  const logWarn = logger.warn.bind(logger);

  logger.warn = (msg) => {
    if (!msg.includes('Found orphan containers')) {
      logWarn(msg);
    }
  };

  try {
    const status = await runCommand(
      `docker ps -a --filter name=^/${appName}_${containerName}$ --format "{{.Status}}"`,
      logger,
    );

    if (status) {
      if (status.startsWith('Up')) {
        logger.log(`Container is already running.`);
      } else {
        logger.verbose(`Container exists but is stopped. Starting...`);
        await runCommand(`docker start ${appName}_${containerName}`, logger);
        logger.log(`Container has been started.`);
      }
    } else {
      logger.verbose(`Container not found. Creating and starting...`);

      const composeFilePath = path.join(
        __dirname,
        `../containers/${containerName}.docker-compose.yml`,
      );

      const command = `docker compose -p autorin -f "${composeFilePath}" --env-file ${
        envFile
      } up -d`;

      await runCommand(command, logger);
      logger.log('Container has been created and started.');
    }
  } catch (error) {
    logger.error(`Failed to start ${containerName}: ${error.message}`);
    process.exit(1);
  }
}

function getRunningContainers(appName) {
  const output = execSync(
    `docker ps -a --format '{{.Names}}' --filter "label=com.docker.compose.project=${appName}"`,
  )
    .toString()
    .trim();

  return output ? output.split('\n') : [];
}

function checkForOrphanContainers(containers, { appName = 'app' } = {}) {
  const expectedNames = containers.map((containerName) => `'${containerName}'`);
  const actualNames = getRunningContainers(appName);

  const orphans = actualNames.filter((name) => !expectedNames.includes(name));

  if (orphans.length > 0) {
    console.warn(`Found extra containers (possibly orphan):`);
    for (const orphan of orphans) {
      console.warn(`  - ${orphan}`);
    }
  }
}

module.exports = {
  runContainer,
  getRunningContainers,
  checkForOrphanContainers,
};
