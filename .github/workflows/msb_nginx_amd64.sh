#!/usr/bin/bash
GITHUB_TOKEN=$1

buildah login -u star-39 -p $GITHUB_TOKEN ghcr.io

#AMD64
c1=$(buildah from docker://nginx:latest)

# Copy nginx template and app link validation json.
buildah run  $c1 -- mkdir -p /etc/nginx/templates
buildah run  $c1 -- mkdir -p /www/.well-known
buildah copy $c1 web/nginx/default.conf.template /etc/nginx/templates/
buildah copy $c1 web/nginx/assetlinks.json /www/.well-known/assetlinks.json

# Build react app
cd web/webapp3/
npm install
PUBLIC_URL=/webapp REACT_APP_HOST=msb39.eu.org npm run build
buildah copy $c1 build/ /webapp
cd ../..

buildah commit $c1 moe-sticker-bot:msb_nginx

buildah push moe-sticker-bot:msb_nginx ghcr.io/star-39/moe-sticker-bot:msb_nginx
