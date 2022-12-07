#!/usr/bin/env node
const ElmPlugin = require('esbuild-plugin-elm');
const EnvFilePlugin = require('./lib/env');
const http = require('http');

require('esbuild')
  .serve(
    {
      servedir: 'web',
    },
    {
      entryPoints: ['web/ts/index.ts', 'web/react/index.tsx'],
      outdir: 'web',
      bundle: true,
      plugins: [EnvFilePlugin, ElmPlugin({ debug: true })],
    },
  )
  .then((esbuildServer) => {
    const { host, port } = esbuildServer;

    http
      .createServer(/.*/,(req, res) => {
        const forwardRequest = (path) => {
          const options = {
            hostname: host,
            port,
            path,
            method: req.method,
            headers: req.headers,
          };

          const proxyReq = http.request(options, (proxyRes) => {
            if (proxyRes.statusCode === 404) {
              // If esbuild 404s the request, assume it's a route needing to
              // be handled by the JS bundle, so forward a second attempt to `/`.
              // https://gist.github.com/martinrue/2896becdb8a5ed81761e11ff2ea5898e
              return forwardRequest('/');
            }

            res.writeHead(proxyRes.statusCode, proxyRes.headers);
            proxyRes.pipe(res, { end: true });
          });

          req.pipe(proxyReq, { end: true });
        };

        forwardRequest(req.url);
      })
      .listen(1234);
  });
