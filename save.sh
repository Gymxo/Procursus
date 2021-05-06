#!/bin/bash
set -e
echo "$@"
output_dir=$(dirname $1)
eval "$@"
mkdir -p $(BUILD_WORK)/$(SUBPROJECTS)/saved-$(basename $1)
cp -rf $output_dir/* $(BUILD_WORK)/$(SUBPROJECTS)/saved-$(basename $1)
