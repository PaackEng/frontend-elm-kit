#!/usr/bin/env bash
if [[ "${1:-}" != 'make' ]] \
  || [[ "$TEST" =~ '--optimize' ]] \
  || [[ "$TEST" =~ '--debug' ]] \
  || [[ "$TEST" =~ '--report=' ]] \
  || [[ "$TEST" =~ '--docs=' ]] \
  ; then
  echo 'Unsupported elm command'
  exit 1
fi

exec 'elm-optimize-level-2' "${@:2}"
