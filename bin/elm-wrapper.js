#!/usr/bin/env node
const { spawn } = require('child_process');

if (process.argv.includes('--debug')) {
  console.log('No debug for release.');
  process.exit(2);
} else if (process.argv[2] == 'make') {
  spawn(
    'elm-optimize-level-2',
    process.argv.slice(3).filter((item) => item !== '--optimize'),
    { stdio: ['pipe', 1, 2] },
  );
} else {
  console.log('Invalid elm command');
  process.exit(1);
}
