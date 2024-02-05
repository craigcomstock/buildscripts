#!/usr/bin/env bash
set -ex
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php --install-dir=/usr/bin
php -r "unlink('composer-setup.php');"
