#!/usr/bin/env node
const path = require('path');
const ElmPlugin = require('esbuild-plugin-elm');
const EnvFilePlugin = require('./lib/env');

require('esbuild').serve(
  {
    servedir: 'web',
    port: 1234,
  },
  {
    entryPoints: ['web/ts/index.ts'],
    outdir: 'web',
    bundle: true,
    plugins: [EnvFilePlugin, ElmPlugin({ debug: true })],
  },
);
