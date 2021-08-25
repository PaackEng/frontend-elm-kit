const _ = require('lodash');
const util = require('util');
const exec = util.promisify(require('child_process').exec);

let plugin = {
  name: 'env',
  async setup(build) {
    const options = build.initialOptions;
    options.define = options.define || {};

    const { stdout } = await exec('git describe --always --tags --dirty=+');
    process.env.GIT_DESCRIBE = stdout.toString().split('\n', 1)[0];

    _.each(process.env, (value, key) => {
      options.define[`process.env.${key}`] = `"${escape(value)}"`;
    });
  },
};

module.exports = plugin;
