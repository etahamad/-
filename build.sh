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
repo init --depth=1 -u https://github.com/xdroid-oss/xd_manifest -b twelve # manifest
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags

git clone https://github.com/etahamad/xd_device_xiaomi_lavender device/xiaomi/lavender
git clone https://github.com/xdroid-devices/xd_vendor_xiaomi_lavender vendor/xiaomi/lavender --depth=1
git clone https://github.com/xdroid-devices/xd_kernel_xiaomi_lavender kernel/xiaomi/lavender --depth=1

# This create a folder at the source directory and bind it to be used as ccache.
echo "ccache setup for a12"
mkdir tempcc
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache
export CCACHE_DIR=$PWD/tempcc
ccache -M 200G -F 0

# Building ROM
echo "Building your ROM..."
. build/envsetup.sh
lunch xdroid_lavender-user # change this to your device lunch command.
mka xd -j$(($(nproc --all) - 4)) # number of CPUs - 4, our servers have vCPUs = RAM GB, so we can't use all of them.

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
