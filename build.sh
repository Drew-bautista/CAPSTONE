#!/usr/bin/env bash
composer install --no-dev --optimize-autoloader
npm install
npm run prod
