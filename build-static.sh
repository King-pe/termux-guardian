#!/usr/bin/env bash
set -euo pipefail
rm -rf dist
mkdir -p dist
cp index.html styles.css app.js manus-routes.json dist/
cp -R public dist/public
printf 'Static dashboard staged in dist/\n'
