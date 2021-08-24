#!/usr/bin/env node
const path = require('path');
const ElmPlugin = require('esbuild-plugin-elm');
const EnvFilePlugin = require('esbuild-envfile-plugin');

require('esbuild').serve(
  { servedir: 'dist', port: 1234 },
  { },
);
