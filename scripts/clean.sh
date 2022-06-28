#!/bin/bash

sourceMake=$1

aosp_path=""
cd ${aosp_path}
source build/envsetup.sh
${sourceMake} clean
