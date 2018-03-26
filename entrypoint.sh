#!/usr/bin/env bash
find /var/lib/mysql -type f -exec touch {} \;
service mysql restart

docker-php-entrypoint "$@"
