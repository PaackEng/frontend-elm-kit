#!/usr/bin/env bash

if [[ "${1:-}" != 'make' ]]; then
  echo 'Invalid elm command'
  exit 1
fi

exec 'elm-optimize-level-2' "${@:2}"
