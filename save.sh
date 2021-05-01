#!/bin/bash
set -e
echo "$@"
output_dir=$(dirname $1)
eval "$@"
mkdir -p /Users/nathan/Procursus/build_work/iphoneos-arm64/1700/gobject-introspection/build/saved-$(basename $1)
cp -rf $output_dir/* /Users/nathan/Procursus/build_work/iphoneos-arm64/1700/gobject-introspection/build/saved-$(basename $1)
