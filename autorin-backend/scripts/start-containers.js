const {
  runContainer,
  checkForOrphanContainers,
} = require('./container-controller.js');
const { setupDocker } = require('./setup-docker.js');
const { services } = require('./config.js');
const { name: appName } = require('../package.json');

async function startContainers() {
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
