#!/usr/bin/env bash

# Welcome Page
echo =============================================
echo  "Welcome to the build script for - project!"
echo =============================================

echo # Enviroment
export KBUILD_BUILD_USER="etahamad" # change this to your name
export KBUILD_BUILD_HOST="the-dash-project" 

# Initial Values
deviceName="lavender" # change this to your device name

# Clone the source
echo "Cloning the source..."
mkdir android
cd android
repo init --depth=1 -u https://github.com/Spark-Rom/manifest -b spark
repo sync -c -j6 --force-sync --no-clone-bundle --no-tags

echo "ccache setup for a12"
sudo mkdir /ccache
sudo mkdir tempcc
umount /ccache
sudo mount --bind $PWD/tempcc /ccache
export USE_CCACHE=1
export CCACHE_EXEC=$(which ccache)
export CCACHE_DIR=/ccache
ccache -M 100G -F 0

# dt
echo "Cloning the device tree..."
git clone https://github.com/Vitorgl2003/device_xiaomi_lavender device/xiaomi/lavender
git clone https://github.com/Vitorgl2003/vendor_xiaomi_lavender vendor/xiaomi/lavender --depth=1
git clone https://github.com/Vitorgl2003/kernel_xiaomi_lavender kernel/xiaomi/lavender --depth=1

git clone https://github.com/Vitorgl2003/device_qcom_sepolicy-legacy-um device/qcom/sepolicy-legacy-um
git clone https://github.com/Vitorgl2003/platform_hardware_qcom-caf_msm8998_audio hardware/qcom-caf/msm8998/audio
git clone https://github.com/Vitorgl2003/platform_hardware_qcom-caf_msm8998_display hardware/qcom-caf/msm8998/display
git clone https://github.com/Vitorgl2003/platform_hardware_qcom-caf_msm8998_media hardware/qcom-caf/msm8998/media
git clone https://github.com/Vitorgl2003/packages_resources_devicesettings packages/resources/devicesettings
git clone https://github.com/Vitorgl2003/device_xiaomi_extras device/xiaomi/extras

# Building ROM
echo "Building your ROM..."
. build/env*
lunch spark_lavender-userdebug # change this to your device lunch command
mka bacon -j60 # change this to your device build command but keep the -j78

echo "Uploading your ROM..."
cd out/target/product/lavender

finalAndroidBuild=$(ls -U *.zip | head -1)
uploader=$(curl --upload-file ./$finalAndroidBuild https://transfer.sh/$finalAndroidBuild)

function uploadTotransfersh() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
         -d chat_id="$chat_id" \
         -d "disable_web_page_preview=true" \
         -d "parse_mode=html" \
         -d text="Your build is ready to be downloaded: $uploader."
}

uploadTotransfersh

echo "Cleaning up..."
# Clean up
