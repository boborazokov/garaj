const { ConsoleLogger } = require('@nestjs/common');
const { runCommand } = require('./cli-utils');
const os = require('os');
const { execSync } = require('child_process');
const { existsSync } = require('fs');
const {
  AUTO_START_DOCKER,
  SKIP_DOCKER,
  dockerDesktopPath,
} = require('./config');

function isDockerCliAvailable() {
  try {
    execSync('docker --version', { stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

function getDockerContext() {
  try {
    const context = execSync('docker context show').toString().trim();
    return context;
  } catch {
    return null;
  }
}

function trySwitchToDefaultContext(logger) {
  const currentContext = getDockerContext();
  if (!currentContext) {
    logger.warn('Could not determine Docker context.');
    return;
  }

  if (currentContext !== 'default') {
    logger.warn(`Current Docker context: ${currentContext}`);
    logger.warn('Attempting to switch to default context...');
    try {
      execSync('docker context use default');
      logger.log('Switched to default context');
    } catch (err) {
      logger.error(`Failed to switch to default context: ${err.message}`);
    }
  }
}

async function tryDockerInfo(logger) {
  try {
    await runCommand('docker info', logger, { quiet: true });
    return true;
  } catch {
    return false;
  }
}

async function tryStartDocker(logger) {
  const platform = os.platform();

  if (!AUTO_START_DOCKER) {
    logger.warn('AUTO_START_DOCKER is disabled. Start Docker manually.');
    return false;
  }

  logger.log('Attempting to start Docker...');

  try {
    if (platform === 'linux') {
      await runCommand('sudo systemctl start docker', logger);
    } else if (platform === 'darwin') {
      await runCommand('open -a Docker', logger);
    } else if (platform === 'win32') {
      if (!existsSync(dockerDesktopPath)) {
        logger.warn(
          `Docker Desktop was not found at: ${dockerDesktopPath}`,
        );
        return false;
      }

      await runCommand(`"${dockerDesktopPath}"`, logger, { quiet: true });
    } else {
      logger.error(
        `Unsupported platform: ${platform}. Please start Docker manually.`,
      );
      return false;
    }

    return true;
  } catch (err) {
    logger.error(`Failed to auto-start Docker: ${err.message}`);
    return false;
  }
}

async function waitForDocker(logger, attempts = 10, delayMs = 2000) {
  for (let i = 0; i < attempts; i++) {
    if (await tryDockerInfo(logger)) {
      logger.log('Docker is running.');
      return true;
    }
    await new Promise((res) => setTimeout(res, delayMs));
  }

  logger.error('Docker did not start in time. Please start Docker manually.');
  return false;
}

async function setupDocker() {
  const logger = new ConsoleLogger('Docker', { timestamp: true });

  if (SKIP_DOCKER) {
    logger.warn('SKIP_DOCKER is enabled. Skipping Docker checks.');
    return;
  }

  logger.log('Checking Docker Engine status...');

  if (!isDockerCliAvailable()) {
    logger.error('Docker CLI is not installed or is missing from PATH.');
    logger.error(
      'Install Docker Desktop or start the app with SKIP_DOCKER=true if MongoDB and MinIO are already running elsewhere.',
    );
    process.exit(1);
  }

  trySwitchToDefaultContext(logger);

  if (await tryDockerInfo(logger)) return;

  const hasStartAttempted = await tryStartDocker(logger);

  if (!hasStartAttempted) {
    logger.error('Docker Engine is not running and could not be auto-started.');
    process.exit(1);
  }

  logger.verbose('Waiting for Docker...');
  const success = await waitForDocker(logger);
  if (!success) {
    logger.error('Docker Engine is not running or could not be started.');
    process.exit(1);
  }
}

module.exports = { setupDocker };
