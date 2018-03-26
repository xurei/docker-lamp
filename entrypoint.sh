#!/usr/bin/env bash
service mysql restart

docker-php-entrypoint "$@"
