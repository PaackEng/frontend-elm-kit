#!/usr/bin/env node
const path = require('path');
const fs = require('fs');
const ElmPlugin = require('esbuild-plugin-elm');
const EnvFilePlugin = require('esbuild-envfile-plugin');

require('esbuild')
  .build({
    entryPoints: ['web/ts/index.ts'],
    outdir: 'dist/js',
    entryNames: '[dir]/[name]-[hash]',
    allowOverwrite: true,
    bundle: true,
    metafile: true,
    minify: true,
    plugins: [EnvFilePlugin, ElmPlugin({ pathToElm: 'paack-elm-wrapper' })],
  })
  .then((result) => {
    const htmlPath = 'dist/index.html';

    fs.copyFile('web/index.html', htmlPath, console.log);

    fs.readFile(htmlPath, 'utf8', (err, data) => {
      if (err) return console.error(err);

      const path = Object.keys(result.metafile.outputs)[0].replace('dist/', '');

      fs.writeFile(
        htmlPath,
        data.replace('index.js', path),
        'utf8',
        console.log,
      );
    });
  });
