#!/usr/bin/env node
const path = require('path');
const fs = require('fs');
const ElmPlugin = require('esbuild-plugin-elm');
const EnvFilePlugin = require('./lib/env.js');

require('esbuild')
  .build({
    entryPoints: ['web/ts/index.ts', 'web/react/index.tsx'],
    outdir: 'dist/js',
    entryNames: '[dir]/[name]-[hash]',
    allowOverwrite: true,
    bundle: true,
    metafile: true,
    minify: true,
    plugins: [EnvFilePlugin, ElmPlugin({ pathToElm: 'paack-elm-wrapper' })],
  })
  .catch(() => process.exit(1))
  .then((result) => {
    const htmlPath = 'dist/index.html';

    fs.copyFile('web/index.html', htmlPath, console.log);

    fs.readFile(htmlPath, 'utf8', (err, data) => {
      if (err) return console.error(err);

      const path = Object.keys(result.metafile.outputs)[0].replace('dist/', '');
      const reactPath = Object.keys(result.metafile.outputs)[1].replace('dist/', '');
      fs.writeFile(
        htmlPath,
        data.replace('/ts/index.js', path).replace('/react/index.js', reactPath),
        'utf8',
        console.log,
      );
    });
  });
