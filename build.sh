#!/bin/bash

# Welcome Page
echo  "Welcome to the build script for etahamad/ci project!"

echo # Enviroment
export KBUILD_BUILD_USER="etahamad" # change this to your name.
export KBUILD_BUILD_HOST="etahamadCI" # this tells that you compiled your rom on my project, you can change it or leave it, your call.

# Initial Values
deviceName="lavender" # change this to your device name.

# Clone the source
echo "Cloning the source..."
mkdir android
cd android
repo init --depth=1 -u #source
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags

# This create a folder at the source directory and bind it to be used as ccache.
echo "ccache setup for a12"
sudo mkdir /ccache
mkdir tempcc
sudo umount /ccache
sudo mount --bind $PWD/tempcc /ccache
export USE_CCACHE=1
export CCACHE_EXEC=$(which ccache)
export CCACHE_DIR=/ccache
ccache -M 200G -F 0

# Building ROM
echo "Building your ROM..."
. build/env*
lunch # change this to your device lunch command.
mka bacon -j$(($(nproc --all) - 4)) # number of CPUs - 4, our servers have vCPUs = RAM GB, so we can't use all of them.

echo "Uploading your ROM..."
cd out/target/product/lavender # change this to your device name.

function sendNotify() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
         -d chat_id="$chat_id" \
         -d "disable_web_page_preview=true" \
         -d "parse_mode=html" \
         -d text="Your build is ready to be downloaded: $(curl --upload-file ./$(ls -U *.zip | head -1) \ https://transfer.sh/$(ls -U *.zip | head -1))."
}

sendNotify
