#!/bin/bash
set -e
echo "$@"
output_dir=$(dirname $1)
mkdir -p /Users/nathan/Procursus/build_work/iphoneos-arm64/1700/gobject-introspection/build/saved-$(basename $1)
cp -rf /Users/nathan/Procursus/build_work/iphoneos-arm64/1700/gobject-introspection/build/saved-$(basename $1)/*.txt $output_dir/
cp -rf /Users/nathan/Procursus/build_work/iphoneos-arm64/1700/gobject-introspection/build/saved-$(basename $1)/*.xml $output_dir/
