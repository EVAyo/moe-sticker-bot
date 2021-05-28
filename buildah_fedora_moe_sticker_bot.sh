#!/bin/bash

GITHUB_TOKEN=$1

echo "Building moe-sticker-bot for Github Container Registry!"

c1=$(buildah from fedora:34)

# prepare repos
# buildah run $c1 -- dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-34.noarch.rpm -y

# install system dependencies
buildah run $c1 -- dnf install python3.9 python-pip bsdtar ImageMagick libwebp curl -y
curl -Lo ffmpeg.tar.xz https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz
bsdtar -xvf ffmpeg.tar.xz --strip-components=1
buildah copy $c1 ffmpeg /usr/bin/ffmpeg

# grab sources
buildah run $c1 -- curl -Lo /moe-sticker-bot.zip https://github.com/star-39/moe-sticker-bot/archive/refs/heads/master.zip 
buildah run $c1 -- bsdtar -xvf /moe-sticker-bot.zip -C /

# install python dependencies
buildah run $c1 -- pip3 install -r /moe-sticker-bot-master/requirements.txt

# finish
buildah config --cmd '' $c1
buildah config --entrypoint "cd /moe-sticker-bot-master && /usr/bin/python3 main.py" $c1

# Fix python3.8+'s problem.
buildah config --env COLUMNS=80 $c1

# clean up
buildah run $c1 -- dnf autoremove python3-pip
buildah run $c1 -- dnf clean all

buildah commit $c1 moe-sticker-bot

buildah login -u star-39 -p $GITHUB_TOKEN ghcr.io

buildah push moe-sticker-bot ghcr.io/star-39/moe-sticker-bot:latest

