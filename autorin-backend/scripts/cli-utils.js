const { exec } = require('child_process');

function runCommand(command, logger, { quiet = false } = {}) {
  return new Promise((resolve, reject) => {
    exec(command, (error, stdout, stderr) => {
      if (!quiet) {
        if (stdout?.trim()) logger?.verbose?.(stdout.trim());
        if (stderr?.trim()) logger?.warn?.(stderr.trim());
      }

      if (error) {
        if (!quiet) {
          logger?.error?.(`Error executing command: ${error.message}`);
        }
        return reject(error);
      }

      if (!quiet && stdout) logger?.log?.(stdout.trim());
      if (!quiet && stderr) logger?.warn?.(stderr.trim());
      resolve(stdout);
    });
  });
}

module.exports = { runCommand };
