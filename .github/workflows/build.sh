#!/usr/bin/env bash

# Main exports

cd kernel
# Kernel naming
NAME=Chips
KERNELVERSION=$(make kernelversion)

# CI
DISTRO=$(cat /etc/issue)
TANGGAL=$(date +"%F")
START=$(date +"%s")
PROCS=$(nproc --all)
CI_BRANCH=$(git rev-parse --abbrev-ref HEAD)
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
KERNEL_DIR=$(pwd)
PATH="${KERNEL_DIR}/clang/bin:${KERNEL_DIR}/gcc/bin:${KERNEL_DIR}/gcc32/bin:${PATH}"
export KBUILD_COMPILER_STRING="$(${KERNEL_DIR}/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
export ARCH=arm64

# 
export KBUILD_BUILD_HOST=omarci
export KBUILD_BUILD_USER="etahamad"

# Set a commit head
COMMIT_HEAD=$(git log --oneline -1)

# Set Date 
DATE=$(TZ=Africa/Cairo date +"%Y%m%d-%s")

# The name of the device for which the kernel is built
MODEL="Xiaomi Redmi Note 7"

# The codename of the device
DEVICE="Lavender"

#Check Kernel Version
KERVER=$(make kernelversion)

function sendinfo() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="<b>CI Build Triggered</b>%0A<b>Build Number: </b><code>$GITHUB_RUN_NUMBER</code>%0A<b>OS: </b><code>$DISTRO</code>%0A<b>Kernel Version: </b><code>$KERVER</code>%0A<b>Camera Version: </b><code>$CAM</code>%0A<b>Date: </b><code>$(TZ=Africa/Cairo date)</code>%0A<b>Device: </b><code>$MODEL [$DEVICE]</code>%0A<b>Pipeline Host: </b><code>$KBUILD_BUILD_HOST</code>%0A<b>Host Core Count: </b><code>$PROCS</code>%0A<b>Compiler Used: </b><code>$KBUILD_COMPILER_STRING</code>%0A<b>Branch: </b><code>$CI_BRANCH</code>%0A<b>Top Commit: </b><code>$COMMIT_HEAD</code>"
}

function finerr() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Build throw an error(s)"
    exit 1
}

function compile() {
    make O=out ARCH=arm64 lavender_defconfig
    make -j$(nproc --all) O=out \
                    ARCH=arm64 \
                    CC=clang \
                    CLANG_TRIPLE=aarch64-linux-gnu- \
                    CROSS_COMPILE=aarch64-linux-android- \
                    CROSS_COMPILE_ARM32=arm-linux-androideabi-

    if ! [ -a "$IMAGE" ]; then
        finerr
        exit 1
    fi
    cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
}
function zipping() {
    cd AnyKernel || exit 1
    zip -r9 ${NAME}-v${KERNELVERSION}-${CAM}-${TANGGAL}.zip *
    cd ..
}

function push() {
    cd AnyKernel
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot$token/sendDocument" \
        -F chat_id="$chat_id" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build took: $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)"
}

sendinfo
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push
