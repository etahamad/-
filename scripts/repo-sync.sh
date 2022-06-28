#!/bin/bash

aosp_path=""
cd ${aosp_path}
repo sync -c -j4 --force-sync --no-clone-bundle --no-tags
