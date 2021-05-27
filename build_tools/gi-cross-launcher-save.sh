#!/bin/bash
set -e
echo "$@"
output_dir=$(dirname $1)
eval "$@"
mkdir -p ${BUILD_ROOT}/build_work/darwin-amd64/1600/gir-functions/saved-$(basename $1)
cp -rf $output_dir/* ${BUILD_ROOT}/build_work/darwin-amd64/1600/gir-functions/saved-$(basename $1)
