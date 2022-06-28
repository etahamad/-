sourceMake=$1
sourceName=$2
productName=$3
buildType=$4

# ex: mka xd lavender user

aosp_path=""

# Setup environment (Step 1)
environment_Setup() {
    echo "**********************Initiating Environment**********************"
    source build/envsetup.sh
    lunch ${sourceName}_${productName}-${buildType}
}

#System Image build (Step 2)
system_image() {
    echo "**********************Initiating System Image Build **********************"
    ${sourceMake} ${sourceName} -j$(($(nproc --all) - 4))
    TARGET_FILE=out/target/product/${productName}/$(ls -U *.zip | head -1)
    echo $TARGET_FILE
    if [ ! -f "$TARGET_FILE" ]; then
        echo "BUILD FAILURE. Please check for the build errors"
        exit 1
    fi
}

#Post Build Setup  (Step 3)
post_build_setup() {
    echo "**********************Initiating post Build Setup**********************"
    cd out/target/product/${productName}
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
         -d chat_id="$chat_id" \
         -d "disable_web_page_preview=true" \
         -d "parse_mode=html" \
         -d text="Your build is ready to be downloaded: $(curl --upload-file ./$(ls -U *.zip | head -1) https://transfer.sh/$(ls -U *.zip | head -1))."
}

#Execution Sequence
cd ${aosp_path}
environment_Setup
system_image
post_build_setup
