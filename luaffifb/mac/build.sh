#!/bin/bash

path=`dirname $0`

OUTPUT_DIR=$1
TARGET_NAME=plugin_luaffifb
OUTPUT_SUFFIX=dylib
CONFIG=Release

#
# Checks exit value for error
# 
checkError() {
    if [ $? -ne 0 ]
    then
        echo "Exiting due to errors (above)"
        exit -1
    fi
}

# 
# Canonicalize relative paths to absolute paths
# 
pushd $path > /dev/null
dir=`pwd`
path=$dir
popd > /dev/null

if [ -z "$OUTPUT_DIR" ]
then
    OUTPUT_DIR=.
fi

pushd $OUTPUT_DIR > /dev/null
dir=`pwd`
OUTPUT_DIR=$dir
popd > /dev/null

echo "OUTPUT_DIR: $OUTPUT_DIR"

pushd $OUTPUT_DIR/../shared
make
mv ffi.so $OUTPUT_DIR/ffi.dylib
popd

#cp "$path/build/Release/$TARGET_NAME.$OUTPUT_SUFFIX" "$OUTPUT_DIR"