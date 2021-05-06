#!/bin/bash
set -e
echo "$@"
output_dir=$(dirname $1)
mkdir -p $(BUILD_WORK)/$(SUBPROJECTS)/saved-$(basename $1)
cp -rf $(BUILD_WORK)/$(SUBPROJECTS)/saved-$(basename $1)/*.txt $output_dir/
cp -rf $(BUILD_WORK)/$(SUBPROJECTS)/saved-$(basename $1)/*.xml $output_dir/
