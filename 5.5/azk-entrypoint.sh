#!/bin/bash
set -e

export MYSQL_PASSWORD="${MYSQL_PASSWORD:-$MYSQL_PASS}"

exec /entrypoint.sh "$@"
